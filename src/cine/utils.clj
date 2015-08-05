(ns cine.utils
  (:require [clojure.string :as str])
  (:gen-class))

(defn month-to-num [^String month]
  (let [month-db {:january 1
                  :february 2
                  :march 3
                  :april 4
                  :may 5
                  :june 6
                  :july 7
                  :august 8
                  :september 9
                  :october 10
                  :november 11
                  :december 12}]
    (month-db (keyword (str/lower-case month)))))
