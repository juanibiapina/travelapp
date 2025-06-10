import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

// Connects to data-controller="map"
export default class extends Controller {
  connect() {
    // Set Mapbox access token
    // In production, this should be set via environment variable
    mapboxgl.accessToken = this.data.get("token") || "pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw"
    
    // Initialize the map centered on Berlin
    this.map = new mapboxgl.Map({
      container: this.element,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [13.4050, 52.5200], // Berlin coordinates
      zoom: 12
    })

    // Add a marker for Berlin
    new mapboxgl.Marker({
      color: '#3B82F6' // Blue color to match the design
    })
    .setLngLat([13.4050, 52.5200])
    .setPopup(new mapboxgl.Popup().setHTML('<div class="text-center"><strong>Berlin, Germany</strong><br>Trip Location</div>'))
    .addTo(this.map)

    // Add navigation controls
    this.map.addControl(new mapboxgl.NavigationControl())
  }

  disconnect() {
    // Clean up the map instance
    if (this.map) {
      this.map.remove()
    }
  }
}