import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields"]

  connect() {
    this.updateVisibility()
  }

  toggle() {
    this.updateVisibility()
  }

  updateVisibility() {
    const checkbox = this.element.querySelector('input[type="checkbox"][name*="is_recurring"]')
    
    if (!this.hasFieldsTarget) {
      return
    }
    
    if (checkbox && checkbox.checked) {
      this.fieldsTarget.classList.remove("hidden")
    } else {
      this.fieldsTarget.classList.add("hidden")
    }
  }
}
