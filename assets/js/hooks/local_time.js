const formatLocalDateTime = isoDateTime => {
  const parsed = new Date(isoDateTime)
  if (Number.isNaN(parsed.getTime())) return null

  return new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(parsed)
}

const LocalTime = {
  mounted() {
    this.renderLocalTimes()
  },

  updated() {
    this.renderLocalTimes()
  },

  renderLocalTimes() {
    this.el.querySelectorAll("[data-local-datetime]").forEach(node => {
      const iso = node.getAttribute("data-local-datetime")
      if (!iso) return

      const formatted = formatLocalDateTime(iso)
      if (!formatted) return

      node.textContent = formatted
      node.setAttribute("title", formatted)
    })
  },
}

export default LocalTime
