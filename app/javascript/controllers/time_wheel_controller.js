import { Controller } from "@hotwired/stimulus"

// iOS-style scrolling time picker. Three snap-scrolling columns
// (hour / minute / AM-PM) write a 24h "HH:MM" value into a hidden field.
export default class extends Controller {
  static targets = ["hours", "minutes", "meridiem", "field", "display"]
  static values = {
    defaultHour: { type: Number, default: 15 },   // 3 PM — school pickup time
    defaultMinute: { type: Number, default: 0 }
  }

  connect() {
    this.itemHeight = 44
    this.buildColumn(this.hoursTarget, this.range(1, 12))
    this.buildColumn(this.minutesTarget, this.range(0, 55, 5).map(m => String(m).padStart(2, "0")))
    this.buildColumn(this.meridiemTarget, ["AM", "PM"])

    const h24 = this.defaultHourValue
    const hour12 = ((h24 + 11) % 12) + 1
    this.scrollToIndex(this.hoursTarget, hour12 - 1, false)
    this.scrollToIndex(this.minutesTarget, Math.round(this.defaultMinuteValue / 5), false)
    this.scrollToIndex(this.meridiemTarget, h24 >= 12 ? 1 : 0, false)

    this.timers = new Map()
    ;[this.hoursTarget, this.minutesTarget, this.meridiemTarget].forEach(col => {
      col.addEventListener("scroll", () => this.onScroll(col), { passive: true })
    })
    this.commit()
  }

  range(from, to, step = 1) {
    const out = []
    for (let i = from; i <= to; i += step) out.push(i)
    return out
  }

  buildColumn(col, values) {
    const spacer = `<div class="h-[88px] shrink-0" aria-hidden="true"></div>`
    col.innerHTML =
      spacer +
      values.map(v =>
        `<div class="time-wheel-item h-11 shrink-0 flex items-center justify-center text-2xl tabular-nums snap-center cursor-pointer" data-value="${v}">${v}</div>`
      ).join("") +
      spacer
    col.querySelectorAll(".time-wheel-item").forEach((el, i) => {
      el.addEventListener("click", () => this.scrollToIndex(col, i, true))
    })
  }

  scrollToIndex(col, index, smooth) {
    col.scrollTo({ top: index * this.itemHeight, behavior: smooth ? "smooth" : "instant" })
  }

  selectedIndex(col) {
    return Math.round(col.scrollTop / this.itemHeight)
  }

  onScroll(col) {
    clearTimeout(this.timers.get(col))
    this.paint(col)
    this.timers.set(col, setTimeout(() => this.commit(), 80))
  }

  paint(col) {
    const idx = this.selectedIndex(col)
    col.querySelectorAll(".time-wheel-item").forEach((el, i) => {
      const d = Math.abs(i - idx)
      el.style.opacity = d === 0 ? "1" : d === 1 ? "0.45" : "0.18"
      el.style.transform = d === 0 ? "scale(1)" : "scale(0.85)"
      el.classList.toggle("font-semibold", d === 0)
    })
  }

  commit() {
    const items = col => col.querySelectorAll(".time-wheel-item")
    const value = col => {
      const list = items(col)
      const idx = Math.min(Math.max(this.selectedIndex(col), 0), list.length - 1)
      return list[idx].dataset.value
    }

    const hour12 = parseInt(value(this.hoursTarget), 10)
    const minute = value(this.minutesTarget)
    const pm = value(this.meridiemTarget) === "PM"
    let h24 = hour12 % 12
    if (pm) h24 += 12

    this.fieldTarget.value = `${String(h24).padStart(2, "0")}:${minute}`
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = `${hour12}:${minute} ${pm ? "PM" : "AM"}`
    }
    ;[this.hoursTarget, this.minutesTarget, this.meridiemTarget].forEach(c => this.paint(c))
  }
}
