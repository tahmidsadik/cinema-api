(ns cine.server
  (:require [clojure.string :as str]
            [compojure.core :refer :all]
            [compojure.route :as route]
            [immutant.web :refer :all]
            [hiccup.core :as h]
            [ring.middleware.defaults :refer :all]
            [cheshire.core :as cheshire ]
            [cine.core :as cine])
  (:gen-class))

(defn current-movie-list-handler [req]
  {:status 200
   :headers {"Content-type" "text"}
   :body (cheshire/generate-string (cine/get-current-movies))})

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
  (let [PORT (Integer/parseInt (or (System/getenv "PORT") "9003"))]  ;; getting PORT number form env-variable $PORT 
                                                              ;;for deploying to heroku
    (run app {:host "localhost" :port PORT})))

