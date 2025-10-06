import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "checkbox", "checkmark", "itemText", "progressBar", "progressText", "completeButton", "markAllButton"]

  connect() {
    console.log("Checklist controller connected")
    this.checkedItems = new Set()
    this.updateProgress()
  }

  toggleItem(event) {
    console.log("Item clicked!")
    event.preventDefault()
    event.stopPropagation()
    
    const item = event.currentTarget
    const index = this.itemTargets.indexOf(item)
    const checkbox = this.checkboxTargets[index]
    const checkmark = this.checkmarkTargets[index]
    const itemText = this.itemTextTargets[index]

    if (this.checkedItems.has(index)) {
      // Uncheck
      this.checkedItems.delete(index)
      checkbox.classList.remove("bg-green-500", "border-green-500")
      checkbox.classList.add("bg-white", "dark:bg-gray-800", "border-gray-300", "dark:border-gray-600")
      checkmark.classList.add("hidden")
      itemText.classList.remove("line-through", "text-gray-500", "dark:text-gray-500")
      item.classList.remove("bg-green-50", "dark:bg-green-900/20", "border-green-300", "dark:border-green-700")
      item.classList.add("bg-gray-50", "dark:bg-gray-900", "border-gray-200", "dark:border-gray-700")
    } else {
      // Check
      this.checkedItems.add(index)
      checkbox.classList.remove("bg-white", "dark:bg-gray-800", "border-gray-300", "dark:border-gray-600")
      checkbox.classList.add("bg-green-500", "border-green-500")
      checkmark.classList.remove("hidden")
      itemText.classList.add("line-through", "text-gray-500", "dark:text-gray-500")
      item.classList.remove("bg-gray-50", "dark:bg-gray-900", "border-gray-200", "dark:border-gray-700")
      item.classList.add("bg-green-50", "dark:bg-green-900/20", "border-green-300", "dark:border-green-700")
      
      // Add a subtle scale animation
      item.style.transform = "scale(0.98)"
      setTimeout(() => {
        item.style.transform = "scale(1)"
      }, 100)
    }

    this.updateProgress()
  }

  markAllComplete() {
    console.log("Mark all as complete clicked!")
    const total = this.itemTargets.length
    
    // Check if all are already checked
    const allChecked = this.checkedItems.size === total
    
    if (allChecked) {
      // Uncheck all
      for (let i = 0; i < total; i++) {
        if (this.checkedItems.has(i)) {
          this.checkedItems.delete(i)
          const checkbox = this.checkboxTargets[i]
          const checkmark = this.checkmarkTargets[i]
          const itemText = this.itemTextTargets[i]
          const item = this.itemTargets[i]
          
          checkbox.classList.remove("bg-green-500", "border-green-500")
          checkbox.classList.add("bg-white", "dark:bg-gray-800", "border-gray-300", "dark:border-gray-600")
          checkmark.classList.add("hidden")
          itemText.classList.remove("line-through", "text-gray-500", "dark:text-gray-500")
          item.classList.remove("bg-green-50", "dark:bg-green-900/20", "border-green-300", "dark:border-green-700")
          item.classList.add("bg-gray-50", "dark:bg-gray-900", "border-gray-200", "dark:border-gray-700")
        }
      }
    } else {
      // Check all
      for (let i = 0; i < total; i++) {
        if (!this.checkedItems.has(i)) {
          this.checkedItems.add(i)
          const checkbox = this.checkboxTargets[i]
          const checkmark = this.checkmarkTargets[i]
          const itemText = this.itemTextTargets[i]
          const item = this.itemTargets[i]
          
          checkbox.classList.remove("bg-white", "dark:bg-gray-800", "border-gray-300", "dark:border-gray-600")
          checkbox.classList.add("bg-green-500", "border-green-500")
          checkmark.classList.remove("hidden")
          itemText.classList.add("line-through", "text-gray-500", "dark:text-gray-500")
          item.classList.remove("bg-gray-50", "dark:bg-gray-900", "border-gray-200", "dark:border-gray-700")
          item.classList.add("bg-green-50", "dark:bg-green-900/20", "border-green-300", "dark:border-green-700")
        }
      }
    }
    
    this.updateProgress()
  }

  updateProgress() {
    const total = this.itemTargets.length
    const checked = this.checkedItems.size
    const percentage = total > 0 ? (checked / total) * 100 : 0
    const allChecked = checked === total && total > 0

    // Update progress bar
    this.progressBarTarget.style.width = `${percentage}%`
    
    // Update progress text
    this.progressTextTarget.textContent = `${checked} / ${total}`

    // Update mark all button text
    if (this.hasMarkAllButtonTarget) {
      if (allChecked) {
        this.markAllButtonTarget.textContent = "Unmark All"
        this.markAllButtonTarget.classList.remove("bg-indigo-100", "dark:bg-indigo-900", "text-indigo-700", "dark:text-indigo-300", "border-indigo-300", "dark:border-indigo-700")
        this.markAllButtonTarget.classList.add("bg-red-100", "dark:bg-red-900", "text-red-700", "dark:text-red-300", "border-red-300", "dark:border-red-700")
      } else {
        this.markAllButtonTarget.textContent = "Mark All as Completed"
        this.markAllButtonTarget.classList.remove("bg-red-100", "dark:bg-red-900", "text-red-700", "dark:text-red-300", "border-red-300", "dark:border-red-700")
        this.markAllButtonTarget.classList.add("bg-indigo-100", "dark:bg-indigo-900", "text-indigo-700", "dark:text-indigo-300", "border-indigo-300", "dark:border-indigo-700")
      }
    }

    // Enable/disable complete button
    if (this.hasCompleteButtonTarget) {
      if (allChecked) {
        this.completeButtonTarget.disabled = false
        this.completeButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      } else {
        this.completeButtonTarget.disabled = true
        this.completeButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      }
    }
  }
}
