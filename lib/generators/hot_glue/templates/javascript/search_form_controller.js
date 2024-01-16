import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search_form"
export default class extends Controller {
  static targets = ["clearButton"];

  connect() {

    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener("click", (event) => {
        event.preventDefault()
        this.element.reset()
      })
    }
  }
}
