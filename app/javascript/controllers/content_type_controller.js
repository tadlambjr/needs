import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "capacityLabel", "roomBooking", "mealTrain", "checklistNeed", "checklistEvent", "categorySelect"]

  connect() {
    // Store the initial category value before toggling
    if (this.hasCategorySelectTarget) {
      this.initialCategoryValue = this.categorySelectTarget.value
    }
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
    
    // Filter category dropdown based on content type
    if (this.hasCategorySelectTarget) {
      this.filterCategories(isEvent)
    }
  }
  
  filterCategories(isEvent) {
    const select = this.categorySelectTarget
    
    // Get categories from data attributes
    const needCategories = JSON.parse(select.dataset.needCategories || '[]')
    const eventCategories = JSON.parse(select.dataset.eventCategories || '[]')
    
    // Get current selection (use initial value if this is first run)
    const currentValue = this.initialCategoryValue || select.value
    // Clear the stored initial value after first use
    if (this.initialCategoryValue) {
      delete this.initialCategoryValue
    }
    
    // Clear all options except prompt
    while (select.options.length > 1) {
      select.remove(1)
    }
    
    // Add appropriate categories
    const categoriesToShow = isEvent ? eventCategories : needCategories
    categoriesToShow.forEach(cat => {
      const option = new Option(cat.text, cat.value)
      select.add(option)
    })
    
    // Try to restore selection if it's valid for the new type
    const validOption = Array.from(select.options).find(opt => opt.value == currentValue)
    if (validOption) {
      select.value = currentValue
    } else {
      select.value = ''
    }
  }
}
