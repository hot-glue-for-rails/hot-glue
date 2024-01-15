import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="time-range-picker"
export default class extends Controller {
  static targets = [ "matchSelector", "start", "end" ];
  connect() {
    console.log("time_range_picker_controller.js connect.....")
  }

  matchSelection(event) {

    console.log("time_range_picker_controller.js matchSelection.....")
    console.log(event.target.value)
    // this.matchSelectorTarget.value = event.target.value

    switch(event.target.value) {
      case "is_at":
        this.startTarget.disabled = false
        this.endTarget.disabled = true
        this.endTarget.value = ""
        break;
      case "is_between":
        this.startTarget.disabled = false
        this.endTarget.disabled = false
        break;
      case "is_at_or_after":
        this.startTarget.disabled = false
        this.endTarget.disabled = true
        this.endTarget.value = ""
        break;
      case "is_before_or_at":
        this.startTarget.disabled = true
        this.startTarget.value = ""
        this.endTarget.disabled = false
        break;
    }
  }
}
