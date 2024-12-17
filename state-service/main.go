package main

import (
	"encoding/json"
	"net/http"
	"sync"

	"github.com/gorilla/mux"
)

// Attribute represents a key-value pair
type Attribute struct {
	Key   string `json:"key"`
	Value bool   `json:"value"`
}

var (
	attributes = make(map[string]bool)
	mu         sync.Mutex
)

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/attributes/{key}", saveAttribute).Methods("POST")
	r.HandleFunc("/attributes/{key}", deleteAttribute).Methods("DELETE")
	r.HandleFunc("/attributes/{key}", getAttribute).Methods("GET")

	http.ListenAndServe(":80", r)
}

func saveAttribute(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	key := vars["key"]

	mu.Lock()
	attributes[key] = true
	mu.Unlock()

	w.WriteHeader(http.StatusCreated)
}

func deleteAttribute(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	key := vars["key"]

	mu.Lock()
	delete(attributes, key)
	mu.Unlock()

	w.WriteHeader(http.StatusNoContent)
}

func getAttribute(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	key := vars["key"]

	mu.Lock()
	value := attributes[key]
	mu.Unlock()

	json.NewEncoder(w).Encode(Attribute{Key: key, Value: value})
}
