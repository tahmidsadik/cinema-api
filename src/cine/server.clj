(ns cine.server
  (:require [clojure.string :as str]
            [compojure.core :refer :all]
            [compojure.route :as route]
            [immutant.web :refer :all]))

(defroutes routes
  (GET "/" [] "HELLO WORLDJ")
  (route/not-found "404 Not found"))


