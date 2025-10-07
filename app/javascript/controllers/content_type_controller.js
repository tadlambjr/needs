import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "capacityLabel", "roomBooking", "mealTrain", "checklistNeed", "checklistEvent"]

  connect() {
    this.toggle()
  }

  toggle() {
    const contentType = this.selectTarget.value
    const isEvent = contentType === "event"
    
    // Update capacity label
    if (this.hasCapacityLabelTarget) {
      this.capacityLabelTarget.textContent = isEvent 
        ? "Attendee Capacity (Max RSVPs)" 
        : "Number of Volunteers Needed"
    }
    
    // Show/hide room booking section (events only)
    if (this.hasRoomBookingTarget) {
      if (isEvent) {
        this.roomBookingTarget.classList.remove("hidden")
      } else {
        this.roomBookingTarget.classList.add("hidden")
      }
    }
    
    // Show/hide meal train option (needs only)
    if (this.hasMealTrainTarget) {
      if (isEvent) {
        this.mealTrainTarget.classList.add("hidden")
      } else {
        this.mealTrainTarget.classList.remove("hidden")
      }
    }
    
    // Show/hide appropriate checklist select
    if (this.hasChecklistNeedTarget && this.hasChecklistEventTarget) {
      if (isEvent) {
        this.checklistNeedTarget.classList.add("hidden")
        this.checklistEventTarget.classList.remove("hidden")
      } else {
        this.checklistNeedTarget.classList.remove("hidden")
        this.checklistEventTarget.classList.add("hidden")
      }
    }
  }
}
