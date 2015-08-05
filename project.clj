(defproject cine "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.7.0"]
                 [enlive "1.1.6"]
                 [clj-time "0.10.0"]
                 [org.immutant/web "2.0.2"]
                 [cheshire "5.5.0"]
                 [compojure "1.4.0"]
                 [ring/ring-defaults "0.1.5"]
                 [ring/ring-json "0.4.0"]
                 [ring/ring-core "1.4.0"]
                 [hiccup "1.0.5"]]
  :main ^:skip-aot cine.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
