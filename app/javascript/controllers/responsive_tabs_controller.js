import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "tab", "overflowButton", "overflowMenu"]

  connect() {
    this.handleResize = this.handleResize.bind(this)
    this.setupTabs()
    window.addEventListener("resize", this.handleResize)
    // Initial check after a brief delay to ensure elements are rendered
    setTimeout(() => this.handleResize(), 100)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }

  setupTabs() {
    // Store original tab data for restoration
    this.originalTabs = this.tabTargets.map(tab => ({
      element: tab,
      originalParent: tab.parentElement,
      originalClasses: tab.className,
      dropdownClasses: tab.dataset.dropdownClasses || ""
    }))
  }

  handleResize() {
    if (!this.hasContainerTarget || this.tabTargets.length === 0) return

    const containerWidth = this.containerTarget.offsetWidth
    const overflowButtonWidth = this.hasOverflowButtonTarget ? 
      this.overflowButtonTarget.offsetWidth + 16 : 0 // Add margin

    // Reset all tabs to main container first
    this.resetTabs()

    // If container is very small, put all tabs in overflow
    if (containerWidth < 200) {
      this.moveAllTabsToOverflow()
      return
    }

    let currentWidth = 0
    let visibleTabs = []
    let overflowTabs = []

    // Calculate which tabs fit
    for (let i = 0; i < this.tabTargets.length; i++) {
      const tab = this.tabTargets[i]
      const tabWidth = tab.offsetWidth

      // For the last tab, we don't need to reserve space for overflow button
      const isLastTab = i === this.tabTargets.length - 1
      const requiredSpace = isLastTab ? 0 : overflowButtonWidth

      if (currentWidth + tabWidth + requiredSpace > containerWidth && visibleTabs.length > 0) {
        // This tab doesn't fit, add it and remaining tabs to overflow
        overflowTabs = this.tabTargets.slice(i)
        break
      }

      visibleTabs.push(tab)
      currentWidth += tabWidth
    }

    // Move overflow tabs to dropdown menu if any
    if (overflowTabs.length > 0 && this.hasOverflowMenuTarget) {
      this.moveTabsToOverflow(overflowTabs)
      this.showOverflowButton()
    } else {
      this.hideOverflowButton()
    }
  }

  moveAllTabsToOverflow() {
    if (this.hasOverflowMenuTarget) {
      this.moveTabsToOverflow(this.tabTargets)
      this.showOverflowButton()
    }
  }

  moveTabsToOverflow(tabs) {
    const menuContainer = this.overflowMenuTarget.querySelector('.py-1')
    if (!menuContainer) return

    tabs.forEach(tab => {
      this.applyDropdownStyling(tab)
      menuContainer.appendChild(tab)
    })
  }

  resetTabs() {
    // Move all tabs back to main container in original order and restore styling
    this.originalTabs.forEach(({ element, originalParent, originalClasses }) => {
      if (element.parentElement !== originalParent) {
        element.className = originalClasses
        originalParent.appendChild(element)
      }
    })
  }

  applyDropdownStyling(tab) {
    const dropdownClasses = tab.dataset.dropdownClasses
    if (dropdownClasses) {
      tab.className = dropdownClasses
    }
  }

  showOverflowButton() {
    if (this.hasOverflowButtonTarget) {
      this.overflowButtonTarget.classList.remove("hidden")
    }
  }

  hideOverflowButton() {
    if (this.hasOverflowButtonTarget) {
      this.overflowButtonTarget.classList.add("hidden")
    }
  }

  toggleOverflowMenu() {
    if (this.hasOverflowMenuTarget) {
      this.overflowMenuTarget.classList.toggle("hidden")
    }
  }

  hideOverflowMenu(event) {
    if (this.hasOverflowMenuTarget && 
        this.hasOverflowButtonTarget &&
        !this.overflowButtonTarget.contains(event?.target) &&
        !this.overflowMenuTarget.contains(event?.target)) {
      this.overflowMenuTarget.classList.add("hidden")
    }
  }
}