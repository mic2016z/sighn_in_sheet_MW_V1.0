import { Controller } from "@hotwired/stimulus"

// Draw-to-sign canvas. Writes a PNG data URL into a hidden field on submit.
export default class extends Controller {
  static targets = ["canvas", "field", "placeholder"]

  connect() {
    const canvas = this.canvasTarget
    const ratio = window.devicePixelRatio || 1
    const rect = canvas.getBoundingClientRect()
    canvas.width = rect.width * ratio
    canvas.height = rect.height * ratio

    this.ctx = canvas.getContext("2d")
    this.ctx.scale(ratio, ratio)
    this.ctx.lineWidth = 2.5
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"
    this.ctx.strokeStyle = "#0f172a"

    this.drawing = false
    this.hasStroke = false

    canvas.addEventListener("pointerdown", this.start.bind(this))
    canvas.addEventListener("pointermove", this.draw.bind(this))
    window.addEventListener("pointerup", this.stop.bind(this))

    this.formEl = this.element.closest("form")
    this.formEl?.addEventListener("submit", () => this.commit())
  }

  point(e) {
    const rect = this.canvasTarget.getBoundingClientRect()
    return [ e.clientX - rect.left, e.clientY - rect.top ]
  }

  start(e) {
    this.drawing = true
    this.hasStroke = true
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
    const [ x, y ] = this.point(e)
    this.ctx.beginPath()
    this.ctx.moveTo(x, y)
  }

  draw(e) {
    if (!this.drawing) return
    const [ x, y ] = this.point(e)
    this.ctx.lineTo(x, y)
    this.ctx.stroke()
  }

  stop() {
    this.drawing = false
  }

  clear() {
    const canvas = this.canvasTarget
    this.ctx.clearRect(0, 0, canvas.width, canvas.height)
    this.hasStroke = false
    this.fieldTarget.value = ""
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.remove("hidden")
  }

  commit() {
    this.fieldTarget.value = this.hasStroke ? this.canvasTarget.toDataURL("image/png") : ""
  }
}
