(ns cine.core
  (:require [net.cgrand.enlive-html :as enlive])
  (:gen-class))

(defn fetch-markup [url]
  (enlive/html-resource (java.net.URL. url)))

(def cinehub-url "http://w3.cineplexbd.com/~ab46419/cineplexbd/index.php")
(def markup (fetch-markup cinehub-url))

(defn get-current-movies 
  "Returns a list of movies that are being aired now" 
  []
  (->> 
    (-> markup
        (enlive/select [:div#left_navigation > :div.user_panel_d_box01])
        (first)
        (enlive/select [:a]))
    (map #(:content %))
    (flatten)))

(defn get-upcoming-movies 
  "Returns a list of upcoming movies" 
  []
  (->> 
    (-> markup
        (enlive/select [:div#left_navigation > :div.user_panel_d_box01])
        (second)
        (enlive/select [:a]))
    (map #(:content %))
    (flatten)))


(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
