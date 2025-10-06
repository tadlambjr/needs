import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["specificTime", "timeInput"]

  toggle(event) {
    const timeSlot = event.target.value
    
    if (timeSlot === "specific_time") {
      this.specificTimeTarget.classList.remove("hidden")
      if (this.hasTimeInputTarget) {
        this.timeInputTarget.setAttribute("required", "required")
      }
    } else {
      this.specificTimeTarget.classList.add("hidden")
      if (this.hasTimeInputTarget) {
        this.timeInputTarget.removeAttribute("required")
      }
    }
  }
}
