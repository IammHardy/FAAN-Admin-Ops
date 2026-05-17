import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    status: String,
    interval: { type: Number, default: 5000 }
  }

  connect() {
    if (this.statusValue === "processing") {
      this.timer = setInterval(() => {
        window.location.reload()
      }, this.intervalValue)
    }
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }
}