const DialogModal = {
  mounted() {
    this.cancelEvent = this.el.dataset.cancelEvent
    this.focusInitialField = () => {
      const focusTarget = this.el.querySelector("[data-autofocus], input, textarea, select")
      if (focusTarget instanceof HTMLElement) {
        focusTarget.focus()
      }
    }

    this.handleCancel = event => {
      event.preventDefault()
      this.el.close()
      this.pushCancelEvent()
    }

    this.el.addEventListener("cancel", this.handleCancel)

    if (!this.el.open) {
      this.el.showModal()
    }

    window.requestAnimationFrame(this.focusInitialField)
  },

  destroyed() {
    this.el.removeEventListener("cancel", this.handleCancel)
    if (this.el.open) {
      this.el.close()
    }
  },

  pushCancelEvent() {
    if (typeof this.cancelEvent === "string" && this.cancelEvent.length > 0) {
      this.pushEvent(this.cancelEvent, {})
    }
  },
}

export default DialogModal
