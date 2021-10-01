import { Controller } from "@hotwired/stimulus"

console.log("defining Confirmable....")
export default class extends Controller {
  static values = { message: String }

  confirm(event) {

    if(!window.confirm(this.message)) {
      event.preventDefault();
      event.stopPropagation()
    }
  }
}