(ns cine.core
  (:require [net.cgrand.enlive-html :as enlive]
            [clojure.string :as str]
            [cine.utils :refer [month-to-num]])
  (:gen-class))

(def cinehub-url "http://w3.cineplexbd.com/~ab46419/cineplexbd/index.php")
(def schedule-url "http://w3.cineplexbd.com/~ab46419/cineplexbd/index.php?visit=schedule/schedules&a=1")
(def movie-list-markup (fetch-url cinehub-url))
(def schedule-markup (fetch-url schedule-url))

(defn fetch-url [url]
  (enlive/html-resource (java.net.URL. url)))

(defn get-current-movies 
  "Returns a list of movies that are being aired now" 
  []
  (->> 
    (-> movie-list-markup
        (enlive/select [:div#left_navigation > :div.user_panel_d_box01])
        (first)
        (enlive/select [:a]))
    (map #(:content %))
    (flatten)))

(defn get-upcoming-movies 
  "Returns a list of upcoming movies" 
  []
  (->> 
    (-> movie-list-markup
        (enlive/select [:div#left_navigation > :div.user_panel_d_box01])
        (second)
        (enlive/select [:a]))
    (map #(:content %))
    (flatten)))

(def schedules-root-divs (-> schedule-markup 
                             (enlive/select [:div#main_body :> [:div (enlive/nth-of-type 2)]])
                             (enlive/select [enlive/root :>  [:div (enlive/nth-of-type 2)]])
                             (enlive/select [enlive/root :> [:div (enlive/nth-of-type 1)]])
                             (enlive/select [enlive/root :> [:div]])))



(defn extract-date [schedule-markup-list]
  (let [date-in-string (apply enlive/text 
                              (enlive/select 
                                (enlive/select schedule-markup-list 
                                               [enlive/root :> [:table (enlive/nth-of-type 1)]]) [:div]))
        date-fmt (str/split date-in-string #",")
        week-day (str/trim (first date-fmt))
        monthly-date (str/split (str/trim (second date-fmt)) #" ")
        month (month-to-num (first monthly-date))
        date (second monthly-date)
        year (str/trim (nth date-fmt 2))]
    {:week-day week-day
     :month (str month)
     :date date
     :year year}))

(defn extract-movielist-from-schedule 
  "Extracts movies from a schedule day"
  [single-schedule-markup]
  (flatten (map #(:content %) (->> (->  single-schedule-markup
                                       (enlive/select [enlive/root :> [:table (enlive/nth-of-type 2)]])
                                       (enlive/select [enlive/root :> [:tr]]))
                                   (map #(enlive/select % [:a]))
                                   (flatten)))))

(def one (first schedules-root-divs))

(flatten (map #(:content %) (->> (->  one
         (enlive/select [enlive/root :> [:table (enlive/nth-of-type 2)]])
         (enlive/select [enlive/root :> [:tr]]))
     (map #(enlive/select % [:td.time]))
     (flatten))))



(extract-date one)
(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
