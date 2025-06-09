import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="responsive-tabs"
export default class extends Controller {
  static targets = ["tab", "visibleContainer", "overflowMenu", "overflowButton", "overflowList"]

  connect() {
    console.log("ResponsiveTabsController connected")
    this.setupObserver()
    this.checkOverflow()
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
    // Use ResizeObserver to detect when the container size changes
    this.resizeObserver = new ResizeObserver(() => {
      console.log("ResizeObserver triggered")
      this.checkOverflow()
    })
    
    this.resizeObserver.observe(this.element)
    
    // Also listen to window resize events as a fallback
    this.windowResizeHandler = () => {
      console.log("Window resize triggered")
      this.checkOverflow()
    }
    
    window.addEventListener('resize', this.windowResizeHandler)
  }

  checkOverflow() {
    console.log("Checking overflow...")
    if (!this.hasVisibleContainerTarget || !this.hasOverflowButtonTarget) {
      console.log("Missing targets")
      return
    }

    const containerWidth = this.visibleContainerTarget.offsetWidth
    const overflowButtonWidth = 48 // Fixed width estimate for the overflow button
    
    console.log("Container width:", containerWidth)
    
    // First, make all tabs visible to measure their true widths
    this.tabTargets.forEach(tab => tab.classList.remove('hidden'))
    
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
    
    console.log("Total needed width:", totalNeededWidth, "Available width:", containerWidth)
    
    // Check if we need overflow menu
    if (totalNeededWidth <= containerWidth) {
      console.log("All tabs fit, hiding overflow menu")
      // All tabs fit, hide overflow menu
      this.overflowMenuTarget.classList.add('hidden')
      return
    }
    
    console.log("Tabs overflow, showing overflow menu")
    
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
    
    console.log("Visible tabs:", visibleTabs.length, "Overflow tabs:", overflowTabs.length)
    
    this.updateTabVisibility(visibleTabs, overflowTabs)
  }

  updateTabVisibility(visibleTabs, overflowTabs) {
    // Show/hide tabs in main container
    this.tabTargets.forEach(tab => {
      if (visibleTabs.includes(tab)) {
        tab.classList.remove('hidden')
      } else {
        tab.classList.add('hidden')
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
