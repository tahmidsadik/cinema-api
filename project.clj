(defproject cine "0.1"
  :description "Cineplex Movie Schedules as a Service"
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
                 [hiccup "1.0.5"]
                 [ring/ring-devel "1.4.0"]
                 [org.clojure/core.async "0.1.346.0-17112a-alpha"]
                 [http-kit "2.1.19"]]
  :main ^:skip-aot cine.server
  :target-path "target/%s"
  :min-lein-version "2.0.0"
  :uberjar-name "cine-buddy.jar"
  :profiles {:uberjar {:aot :all}})
