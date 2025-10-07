import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "capacityLabel", "roomBooking"]

  connect() {
    this.toggle()
  }

  toggle() {
    const contentType = this.selectTarget.value
    const isEvent = contentType === "event"
    
    // Update capacity label
    if (this.hasCapacityLabelTarget) {
      this.capacityLabelTarget.textContent = isEvent 
        ? "Attendee Capacity" 
        : "Number of Volunteers Needed"
    }
    
    // Show/hide room booking section
    if (this.hasRoomBookingTarget) {
      if (isEvent) {
        this.roomBookingTarget.classList.remove("hidden")
      } else {
        this.roomBookingTarget.classList.add("hidden")
      }
    }
  }
}
