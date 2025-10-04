import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static values = { theme: String }

  connect() {
    // Load saved theme or default to system preference
    const savedTheme = localStorage.getItem('theme') || 'system'
    this.setTheme(savedTheme)
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    let newTheme
    
    if (currentTheme === 'light') {
      newTheme = 'dark'
    } else if (currentTheme === 'dark') {
      newTheme = 'system'
    } else {
      newTheme = 'light'
    }
    
    this.setTheme(newTheme)
  }

  setTheme(theme) {
    localStorage.setItem('theme', theme)
    
    const html = document.documentElement
    
    if (theme === 'dark') {
      html.classList.add('dark')
      this.updateIcon('dark')
    } else if (theme === 'light') {
      html.classList.remove('dark')
      this.updateIcon('light')
    } else {
      // System preference
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        html.classList.add('dark')
        this.updateIcon('system-dark')
      } else {
        html.classList.remove('dark')
        this.updateIcon('system-light')
      }
    }
  }

  getCurrentTheme() {
    return localStorage.getItem('theme') || 'system'
  }

  updateIcon(mode) {
    const sunIcon = document.getElementById('theme-toggle-light-icon')
    const moonIcon = document.getElementById('theme-toggle-dark-icon')
    const systemIcon = document.getElementById('theme-toggle-system-icon')
    
    if (!sunIcon || !moonIcon || !systemIcon) return
    
    sunIcon.classList.add('hidden')
    moonIcon.classList.add('hidden')
    systemIcon.classList.add('hidden')
    
    if (mode === 'light') {
      sunIcon.classList.remove('hidden')
    } else if (mode === 'dark') {
      moonIcon.classList.remove('hidden')
    } else {
      systemIcon.classList.remove('hidden')
    }
  }
}
