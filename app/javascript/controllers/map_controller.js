import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class extends Controller {
  connect() {
    // Create a simple map placeholder for Berlin
    // In production, integrate with Mapbox using a real API token
    
    this.element.innerHTML = `
      <div class="flex items-center justify-center h-full bg-gray-100 rounded-lg">
        <div class="text-center">
          <div class="w-16 h-16 bg-blue-500 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900">Berlin, Germany</h3>
          <p class="text-sm text-gray-600 mt-2">Trip Location</p>
          <p class="text-xs text-gray-500 mt-4">Map placeholder - Ready for Mapbox integration</p>
        </div>
      </div>
    `
  }

  disconnect() {
    // Cleanup if needed
  }
}