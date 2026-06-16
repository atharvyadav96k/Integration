package hubspotwebhook

import (
	"encoding/json"
	"io"
	"log"
	"net/http"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("HubSpotWebhook", hubSpotWebhook)
}

func hubSpotWebhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "failed to read body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	var payload any
	if err := json.Unmarshal(body, &payload); err != nil {
		log.Printf("raw payload: %s", body)
		w.WriteHeader(http.StatusOK)
		return
	}

	pretty, _ := json.MarshalIndent(payload, "", "  ")
	log.Printf("payload:\n%s", pretty)

	w.Header().Set("Content-Type", "application/json")
	w.Write(pretty)
}
