const DEFAULT_AUTO_DISMISS_MS = 5000

const normalizeDelay = value => {
  const parsed = Number.parseInt(value ?? "", 10)

  if (Number.isFinite(parsed) && parsed > 0) {
    return parsed
  }

  return DEFAULT_AUTO_DISMISS_MS
}

const FlashAutoDismiss = {
  mounted() {
    this.dismissButton = this.el.querySelector("[data-role='toast-close']")
    this.timerId = null
    this.remainingMs = normalizeDelay(this.el.dataset.autoDismissMs)
    this.deadline = null

    this.startTimer = () => {
      if (!(this.dismissButton instanceof HTMLElement)) return

      this.clearTimer()
      this.deadline = Date.now() + this.remainingMs
      this.timerId = window.setTimeout(() => this.dismiss(), this.remainingMs)
    }

    this.pauseTimer = () => {
      if (this.timerId === null || this.deadline === null) return

      this.remainingMs = Math.max(this.deadline - Date.now(), 0)
      this.clearTimer()
    }

    this.resumeTimer = () => {
      if (this.remainingMs <= 0) {
        this.dismiss()
        return
      }

      this.startTimer()
    }

    this.restartTimer = () => {
      this.remainingMs = normalizeDelay(this.el.dataset.autoDismissMs)
      this.startTimer()
    }

    this.handleMouseEnter = () => this.pauseTimer()
    this.handleMouseLeave = () => this.resumeTimer()
    this.handleFocusIn = () => this.pauseTimer()
    this.handleFocusOut = event => {
      if (!this.el.contains(event.relatedTarget)) {
        this.resumeTimer()
      }
    }

    this.el.addEventListener("mouseenter", this.handleMouseEnter)
    this.el.addEventListener("mouseleave", this.handleMouseLeave)
    this.el.addEventListener("focusin", this.handleFocusIn)
    this.el.addEventListener("focusout", this.handleFocusOut)

    this.restartTimer()
  },

  updated() {
    this.restartTimer()
  },

  destroyed() {
    this.el.removeEventListener("mouseenter", this.handleMouseEnter)
    this.el.removeEventListener("mouseleave", this.handleMouseLeave)
    this.el.removeEventListener("focusin", this.handleFocusIn)
    this.el.removeEventListener("focusout", this.handleFocusOut)
    this.clearTimer()
  },

  dismiss() {
    if (this.dismissButton instanceof HTMLElement) {
      this.dismissButton.click()
    }
  },

  clearTimer() {
    if (this.timerId !== null) {
      window.clearTimeout(this.timerId)
      this.timerId = null
    }

    this.deadline = null
  },
}

export default FlashAutoDismiss
