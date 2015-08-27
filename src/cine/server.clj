(ns cine.server
  (:require [clojure.string :as str]
            [clojure.java.io :as io]
            [compojure.core :refer :all]
            [compojure.route :as route]
            [immutant.web :refer :all]
            [hiccup.core :as h]
            [ring.middleware.defaults :refer :all]
            [cheshire.core :as cheshire ]
            [org.httpkit.client :as http]
            [clojure.core.async :as a :refer [go <! >! <!! >!!]]
            [cine.core :as cine])
  (:gen-class))

(defn http-get [url]
  (let [c (a/chan)]
    (http/get url #(a/put! c %))
    c))

(defn add-3d-info [mov]
  (if (.contains (str/lower-case (:name mov)) "3d")
    (assoc mov :3d true)
    (assoc mov :3d false)))

(defn strip-x
  "Strips 'x' from name where 'x' is a string or char-sequence or regexp"
  [string x]
  (str/replace string x ""))

(defn list-movies
  "Takes a list of current of upcoming movies and organizes them in a map."
  [lst]
  (->> lst
       (map add-3d-info)
       (map #(assoc % :name (-> (:name %) 
                                (strip-x "(3D)")
                                (strip-x "(2D)"))))
       (map #(assoc % :imdb-name (-> (:name %)
                                     (str/trim)
                                     (str/replace "-" "")
                                     (str/replace "  " " ")
                                     (str/replace " " "+"))))))

(defn list-current-movies []
  (list-movies (cine/mapify-current-movies)))

(defn list-upcoming-movies []
  (list-movies (cine/mapify-upcoming-movies)))

(defn get-imdb-info [mov-name] 
  (http-get (str "http://www.omdbapi.com/?t=" mov-name)))

(defn current-movie-list-handler [req]
  {:status 200
   :headers {"Content-type" "text"}
   :body (cheshire/generate-string (->> (list-current-movies)
                                        (map #(assoc % :imdb-chan (get-imdb-info (:imdb-name %))))
                                        (map #(assoc % :imdb-info (cheshire/parse-string (:body (<!! (:imdb-chan %))))))
                                        (map #(dissoc % :imdb-chan))))})

(defn upcoming-movie-list-handler [req]
  {:status 200
   :headers {"Content-type" "text"}
   :body (cheshire/generate-string (->> (list-upcoming-movies)
                                        (map #(assoc % :imdb-chan (get-imdb-info (:imdb-name %))))
                                        (map #(assoc % :imdb-info (cheshire/parse-string (:body (<!! (:imdb-chan %))))))
                                        (map #(dissoc % :imdb-chan))))})

(defn cine-schedule-handler [req]
  {:status 200
   :headers {"Content-type" "text"}
   :body (cheshire/generate-string (cine/get-weekly-movie-schedule))})

(defroutes app-routes
  (GET "/" [] "Hello World")
  (GET "/cineplex/current" [] current-movie-list-handler)
  (GET "/cineplex/upcoming" [] upcoming-movie-list-handler)
  (GET "/cineplex/schedule" [] cine-schedule-handler)
  (route/not-found "404 Not found"))

(def app
  (-> app-routes
      (wrap-defaults site-defaults)))

(defn -main
  "Starting the immutant server"
  []
  (let [PORT (Integer/parseInt (or (System/getenv "PORT") "9003"))]  ;; getting PORT number form env-variable $PORT for deploying to heroku
    (run-dmc app {:host "0.0.0.0" :port PORT})))

