import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="responsive-tabs"
export default class extends Controller {
  static targets = ["tab", "visibleContainer", "overflowMenu", "overflowButton", "overflowList"]

  connect() {
    this.setupObserver()
    // Use requestAnimationFrame to ensure DOM is ready
    requestAnimationFrame(() => {
      this.checkOverflow()
    })
  }

  disconnect() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }
    if (this.windowResizeHandler) {
      window.removeEventListener('resize', this.windowResizeHandler)
    }
  }

  setupObserver() {
    // Throttle overflow check to avoid excessive calls
    this.throttledCheckOverflow = this.throttle(this.checkOverflow.bind(this), 100)
    
    // Use ResizeObserver to detect when the container size changes
    this.resizeObserver = new ResizeObserver(() => {
      this.throttledCheckOverflow()
    })
    
    this.resizeObserver.observe(this.element)
    
    // Also listen to window resize events as a fallback
    this.windowResizeHandler = () => {
      this.throttledCheckOverflow()
    }
    
    window.addEventListener('resize', this.windowResizeHandler)
  }

  throttle(func, delay) {
    let timeoutId
    return (...args) => {
      clearTimeout(timeoutId)
      timeoutId = setTimeout(() => func(...args), delay)
    }
  }

  checkOverflow() {
    if (!this.hasVisibleContainerTarget || !this.hasOverflowButtonTarget) {
      return
    }

    // Get parent container width (the flex container that holds both visible tabs and overflow menu)
    const parentContainer = this.visibleContainerTarget.parentElement
    const containerWidth = parentContainer.offsetWidth
    const overflowButtonWidth = 48 // Fixed width estimate for the overflow button
    
    // First, make all tabs visible to measure their true widths
    this.tabTargets.forEach(tab => {
      tab.classList.remove('hidden')
      tab.style.display = ''
    })
    
    // Wait for layout to update before measuring
    requestAnimationFrame(() => {
      // Calculate total width needed for all tabs
      let totalTabsWidth = 0
      const tabWidths = []
      
      this.tabTargets.forEach(tab => {
        const tabWidth = tab.offsetWidth
        tabWidths.push(tabWidth)
        totalTabsWidth += tabWidth
      })
      
      // Add spacing between tabs (space-x-8 = 32px between each tab)
      const totalSpacing = Math.max(0, (this.tabTargets.length - 1) * 32)
      const totalNeededWidth = totalTabsWidth + totalSpacing
      
      // Check if we need overflow menu
      if (totalNeededWidth <= containerWidth) {
        // All tabs fit, hide overflow menu
        this.overflowMenuTarget.classList.add('hidden')
        return
      }
      
      // Calculate available width when overflow button is visible
      const availableWidth = containerWidth - overflowButtonWidth
      
      // Determine which tabs can fit
      let currentWidth = 0
      let visibleTabs = []
      let overflowTabs = []
      
      for (let i = 0; i < this.tabTargets.length; i++) {
        const tabWidth = tabWidths[i] + (i > 0 ? 32 : 0) // Add spacing for all but first tab
        
        if (currentWidth + tabWidth <= availableWidth && visibleTabs.length < this.tabTargets.length - 1) {
          // Always keep at least one tab for overflow
          currentWidth += tabWidth
          visibleTabs.push(this.tabTargets[i])
        } else {
          overflowTabs.push(this.tabTargets[i])
        }
      }
      
      // Ensure at least one tab is visible
      if (visibleTabs.length === 0 && this.tabTargets.length > 0) {
        visibleTabs.push(this.tabTargets[0])
        overflowTabs = this.tabTargets.slice(1)
      }
      
      this.updateTabVisibility(visibleTabs, overflowTabs)
    })
  }

  updateTabVisibility(visibleTabs, overflowTabs) {
    // Show/hide tabs in main container
    this.tabTargets.forEach(tab => {
      if (visibleTabs.includes(tab)) {
        tab.classList.remove('hidden')
        tab.style.display = ''
      } else {
        tab.classList.add('hidden')
        tab.style.display = 'none'
      }
    })
    
    // Update overflow menu
    this.overflowListTarget.innerHTML = ''
    
    if (overflowTabs.length > 0) {
      this.overflowMenuTarget.classList.remove('hidden')
      
      overflowTabs.forEach(tab => {
        const menuItem = this.createOverflowMenuItem(tab)
        this.overflowListTarget.appendChild(menuItem)
      })
    } else {
      this.overflowMenuTarget.classList.add('hidden')
    }
  }

  createOverflowMenuItem(tab) {
    const link = tab.cloneNode(true)
    link.classList.remove('border-b-2', 'py-4', 'px-1', 'hidden')
    link.classList.add('block', 'px-4', 'py-2', 'text-sm', 'hover:bg-gray-100')
    link.style.display = 'block'
    return link
  }

  toggleOverflow() {
    if (this.hasOverflowListTarget) {
      this.overflowListTarget.classList.toggle('hidden')
    }
  }

  hideOverflow() {
    if (this.hasOverflowListTarget) {
      this.overflowListTarget.classList.add('hidden')
    }
  }

  preventClose(event) {
    event.stopPropagation()
  }
}
