(ns cine.core
  (:require [net.cgrand.enlive-html :as enlive]
            [clojure.string :as str]
            [cine.utils :refer [month-to-num]]))

(defn fetch-url [url]
  (enlive/html-resource (java.net.URL. url)))

(def cinehub-url "http://w3.cineplexbd.com/~ab46419/cineplexbd/index.php")
(def schedule-url "http://w3.cineplexbd.com/~ab46419/cineplexbd/index.php?visit=schedule/schedules&a=1")
(def movie-list-markup (fetch-url cinehub-url))
(def schedule-markup (fetch-url schedule-url))


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

(defn mapify-current-movies 
  "Returns current movies in a map e.g. {:name 'MI5'}"
  []
  (map #(assoc {} :name %1) (get-current-movies)))

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

(defn extract-date-markup [single-schedule-markup]
  (apply enlive/text 
         (enlive/select 
           (enlive/select single-schedule-markup 
                          [enlive/root :> [:table (enlive/nth-of-type 1)]]) [:div])))

(defn extract-date [single-schedule-markup]
  (let [date-in-string (extract-date-markup single-schedule-markup)
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

(defn extract-timeschedule-from-schedule 
  "Extracts movie start and end times from a schedule day"
  [single-schedule-markup]
  (partition 5 (flatten (map #(:content %) (->> (->  single-schedule-markup
                                       (enlive/select [enlive/root :> [:table (enlive/nth-of-type 2)]])
                                       (enlive/select [enlive/root :> [:tr]]))
                                   (map #(enlive/select % [:td.time]))
                                   (flatten))))))

(defn make-single-movie-schedule-wo-date [single-schedule-markup]
  (let [movielist (extract-movielist-from-schedule single-schedule-markup)
        timelist (extract-timeschedule-from-schedule single-schedule-markup)]
    (map #(assoc {} :name %1 :schedule %2) movielist timelist)))

(defn make-single-movie-schedule [single-schedule-markup]
  (let [date-map (extract-date single-schedule-markup)
        date-str (str (:date date-map) "/" (:month date-map) "/" (:year date-map))
        mov-schedule (make-single-movie-schedule-wo-date single-schedule-markup)]
    (map #(assoc % :date date-str) mov-schedule)))

(defn get-weekly-movie-schedule []
  (map make-single-movie-schedule schedules-root-divs))
