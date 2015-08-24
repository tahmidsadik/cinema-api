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

(defn add-3d-info [mov]
  (if (.contains (str/lower-case (:name mov)) "3d")
    (assoc mov :3d true)
    (assoc mov :3d false)))

(defn strip-x
  "Strips 'x' from name where 'x' is a string or char-sequence or regexp"
  [string x]
  (str/replace string x ""))

(defn list-movies []
  (->> (cine/mapify-current-movies)
       (map add-3d-info)
       (map #(assoc % :name (-> (:name %) 
                                (strip-x "(3D)")
                                (strip-x "(2D)"))))
       (map #(assoc % :imdb-name (-> (:name %)
                                     (str/trim)
                                     (str/replace "-" "")
                                     (str/replace "  " " ")
                                     (str/replace " " "+"))))))

(defn http-get [url]
  (let [c (a/chan)]
    (http/get url #(a/put! c %))
    c))

(time (let [chans (doall (for [x (list-movies)]
                           (http-get (str "http://www.omdbapi.com/?t=" (:imdb-name x)))))]
        (for [c chans]
          (get (cheshire/parse-string (:body (<!! c))) "Title"))))

(defn current-movie-list-handler [req]
  {:status 200
   :headers {"Content-type" "text"}
   :body (cheshire/generate-string (cine/mapify-current-movies))})

(defn upcoming-movie-list-handler [req]
  {:status 200
   :headers {"Content-type" "text"}
   :body (cheshire/generate-string (cine/get-upcoming-movies))})

(defn cine-schedule-handler [req]
  {:status 200
   :headers {"Content-type" "text"}
   :body (cheshire/generate-string (cine/get-weekly-movie-schedule))})

(defroutes app-routes
  (GET "/" [] "Hello World")
  (GET "/current-cinehub-movies" [] current-movie-list-handler)
  (GET "/upcoming-cinehub-movies" [] upcoming-movie-list-handler)
  (GET "/cinehub-schedule" [] cine-schedule-handler)
  (route/not-found "404 Not found"))

(def app
  (-> app-routes
      (wrap-defaults site-defaults)))

(defn -main
  "Starting the immutant server"
  []
  (let [PORT (Integer/parseInt (or (System/getenv "PORT") "9003"))]  ;; getting PORT number form env-variable $PORT for deploying to heroku
    (run app {:host "0.0.0.0" :port PORT})))

