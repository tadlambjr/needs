// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { Turbo } from "@hotwired/turbo-rails"

// Set up Turbo confirmation dialog with native HTML dialog
Turbo.setConfirmMethod((message, element) => {
  return new Promise((resolve) => {
    // Create dialog element
    const dialog = document.createElement('dialog')
    dialog.style.cssText = 'padding: 0; border: none; background: transparent; max-width: 90vw; max-height: 90vh;'
    
    dialog.innerHTML = `
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-md w-full p-6 m-auto">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Confirm Action</h3>
        <p class="text-gray-600 dark:text-gray-400 mb-6">${message}</p>
        <div class="flex gap-3 justify-end">
          <button class="cancel-btn px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 rounded-md hover:bg-gray-300 dark:hover:bg-gray-600 font-medium">
            Cancel
          </button>
          <button class="confirm-btn px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 font-medium">
            Confirm
          </button>
        </div>
      </div>
    `
    
    document.body.appendChild(dialog)
    dialog.showModal()
    
    // Handle button clicks
    const confirmBtn = dialog.querySelector('.confirm-btn')
    const cancelBtn = dialog.querySelector('.cancel-btn')
    
    const cleanup = () => {
      dialog.close()
      dialog.remove()
    }
    
    confirmBtn.addEventListener('click', () => {
      cleanup()
      resolve(true)
    })
    
    cancelBtn.addEventListener('click', () => {
      cleanup()
      resolve(false)
    })
    
    // Handle ESC key and backdrop click
    dialog.addEventListener('cancel', (e) => {
      e.preventDefault()
      cleanup()
      resolve(false)
    })
    
    dialog.addEventListener('click', (e) => {
      if (e.target === dialog) {
        cleanup()
        resolve(false)
      }
    })
  })
})
