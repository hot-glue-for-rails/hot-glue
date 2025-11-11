import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["clearButton", "textSearch", "textMatch"]

  connect() {
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener("click", (event) => {
        event.preventDefault()
        this.element.reset()
      })
    }

    // watch match selects
    this.textMatchTargets.forEach(target => {
      target.addEventListener("change", this.handleMatchChange)
    })
  }

  textSearchTargetConnected(target) {
    target.addEventListener("input", this.handleSearchInput)
  }

  disconnect() {
    this.textSearchTargets.forEach(target => {
      target.removeEventListener("input", this.handleSearchInput)
    })
    this.textMatchTargets.forEach(target => {
      target.removeEventListener("change", this.handleMatchChange)
    })
  }

  handleSearchInput = (event) => {
    const searchEl = event.target
    const matchEl = this.findMatchFor(searchEl)
    if (!matchEl) return

    const val = searchEl.value.trim()
    const resettable = ["contains", "starts_with", "ends_with"]

    if (val.length > 0 && matchEl.value === "") {
      matchEl.value = "contains"
    } else if (val === "" && resettable.includes(matchEl.value)) {
      matchEl.value = ""
    }
  }

  handleMatchChange = (event) => {
    const matchEl = event.target
    if (matchEl.value !== "") return

    const searchEl = this.findSearchFor(matchEl)
    if (!searchEl) return

    searchEl.value = ""
  }

  findMatchFor(searchEl) {
    const matchName = searchEl.name.replace("search", "match")
    return this.textMatchTargets.find(t => t.name === matchName)
  }

  findSearchFor(matchEl) {
    const searchName = matchEl.name.replace("match", "search")
    return this.textSearchTargets.find(t => t.name === searchName)
  }
}
