import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query", "results", "hiddenFormValue" ]
  static values = { url: String }
  static outlets = [ "typeahead-results" ]

  disconnect() {
    this.reset()
  }

  fetchResults() {
    if(this.query == "") {
      this.reset()
      return
    }

    if(this.query == this.previousQuery) {
      return
    }
    this.previousQuery = this.query

    const url = new URL(this.urlValue)
    url.searchParams.append("query", this.query)

    this.abortPreviousFetchRequest()

    this.abortController = new AbortController()

    fetch(url, { signal: this.abortController.signal })
      .then(response => response.text())
      .then(html => {
        this.resultsTarget.innerHTML = html
      })
      .catch(() => {})
  }

  navigateResults(event) {
    if(this.hasSearchResultsOutlet) {
      this.searchResultsOutlet.navigateResults(event)
    }
  }

  // private

  reset() {
    this.resultsTarget.innerHTML = ""
    this.queryTarget.value = ""
    this.previousQuery = null
  }

  abortPreviousFetchRequest() {
    if(this.abortController) {
      this.abortController.abort()
    }
  }

  get query() {
    return this.queryTarget.value
  }
}
