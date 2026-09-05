import { Controller } from "@hotwired/stimulus"

// Attached to the CSV/Excel export "Download" link that arrives via a Turbo
// Stream broadcast when a background export finishes. On connect it clicks the
// link once, so the file (served with Content-Disposition: attachment)
// downloads automatically without the user having to click.
export default class extends Controller {
  connect() {
    this.element.click()
  }
}
