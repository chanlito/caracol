const SIDEBAR_STORAGE_KEY = "phx:sidebar-state"
const SIDEBAR_STATE_ATTR = "data-sidebar-state"
const DESKTOP_MEDIA_QUERY = "(min-width: 1024px)"
const SIDEBAR_EXPANDED = "expanded"
const SIDEBAR_COLLAPSED = "collapsed"

const sidebarValueValid = value => value === SIDEBAR_EXPANDED || value === SIDEBAR_COLLAPSED

const setSidebarStateAttr = value => {
  document.documentElement.setAttribute(SIDEBAR_STATE_ATTR, value)
}

const getStoredSidebarState = () => {
  try {
    return window.localStorage.getItem(SIDEBAR_STORAGE_KEY)
  } catch {
    return null
  }
}

const saveSidebarState = value => {
  try {
    window.localStorage.setItem(SIDEBAR_STORAGE_KEY, value)
  } catch {
    // Keep UI functional even if browser storage is unavailable.
  }
}

const Sidebar = {
  mounted() {
    this.desktopQuery = window.matchMedia(DESKTOP_MEDIA_QUERY)

    this.syncState = () => {
      if (!this.desktopQuery.matches) {
        this.el.checked = false
        setSidebarStateAttr(SIDEBAR_COLLAPSED)
        return
      }

      const stored = getStoredSidebarState()

      if (sidebarValueValid(stored)) {
        this.el.checked = stored === SIDEBAR_EXPANDED
      }

      setSidebarStateAttr(this.el.checked ? SIDEBAR_EXPANDED : SIDEBAR_COLLAPSED)
    }

    this.handleChange = () => {
      if (!this.desktopQuery.matches) return
      const value = this.el.checked ? SIDEBAR_EXPANDED : SIDEBAR_COLLAPSED
      saveSidebarState(value)
      setSidebarStateAttr(value)
    }

    this.handleDesktopChange = () => this.syncState()

    this.syncState()
    this.el.addEventListener("change", this.handleChange)
    this.desktopQuery.addEventListener("change", this.handleDesktopChange)
  },

  destroyed() {
    this.el.removeEventListener("change", this.handleChange)
    this.desktopQuery.removeEventListener("change", this.handleDesktopChange)
  },
}

export default Sidebar
