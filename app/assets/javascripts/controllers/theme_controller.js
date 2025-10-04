import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  connect() {
    // Load saved theme or default to light
    const savedTheme = localStorage.getItem('theme') || 'light'
    this.setTheme(savedTheme)
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === 'light' ? 'dark' : 'light'
    this.setTheme(newTheme)
  }

  setTheme(theme) {
    localStorage.setItem('theme', theme)
    
    const html = document.documentElement
    
    if (theme === 'dark') {
      html.classList.add('dark')
      this.updateIcon('dark')
    } else {
      html.classList.remove('dark')
      this.updateIcon('light')
    }
  }

  getCurrentTheme() {
    return localStorage.getItem('theme') || 'light'
  }

  updateIcon(mode) {
    const sunIcon = document.getElementById('theme-toggle-light-icon')
    const moonIcon = document.getElementById('theme-toggle-dark-icon')
    
    if (!sunIcon || !moonIcon) return
    
    if (mode === 'light') {
      sunIcon.classList.remove('hidden')
      moonIcon.classList.add('hidden')
    } else {
      sunIcon.classList.add('hidden')
      moonIcon.classList.remove('hidden')
    }
  }
}
