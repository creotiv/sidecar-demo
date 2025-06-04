package main

import (
	"flag"
	"net/http"
	"os"

	"github.com/labstack/echo-contrib/echoprometheus"
	"github.com/labstack/echo/v4"
	"github.com/labstack/gommon/log"
	"github.com/prometheus/client_golang/prometheus"
)

func main() {
	// Allow log path via flag or env var
	var logPath string

	flag.StringVar(&logPath, "log-path", "", "Path to log file")
	flag.Parse()

	if logPath == "" {
		logPath = os.Getenv("LOG_PATH")
		if logPath == "" {
			logPath = "./app.log" // default for local runs
		}
	}

	// Open log file
	logfile, err := os.OpenFile(logPath, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		log.Fatalf("error opening log file: %v", err)
	}

	e := echo.New()
	e.HideBanner = true
	e.HidePort = true
	e.Logger.SetOutput(logfile)
	e.Logger.SetLevel(log.DEBUG)

	customRegistry := prometheus.NewRegistry()
	customCounter := prometheus.NewCounter(prometheus.CounterOpts{
		Name: "custom_requests_total",
		Help: "Total HTTP requests processed.",
	})

	customRegistry.MustRegister(customCounter)
	e.Use(echoprometheus.NewMiddlewareWithConfig(echoprometheus.MiddlewareConfig{
		AfterNext: func(c echo.Context, err error) {
			customCounter.Inc()
		},
		Registerer: customRegistry,
	}))

	e.GET("/metrics", echoprometheus.NewHandlerWithConfig(echoprometheus.HandlerConfig{Gatherer: customRegistry}))
	e.GET("/", func(c echo.Context) error {
		e.Logger.Info("Received request at /")
		return c.String(http.StatusOK, "Hello from Go Echo server!")
	})

	e.Logger.Fatal(e.Start(":8080"))
}
