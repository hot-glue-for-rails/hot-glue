import { Controller } from "@hotwired/stimulus"

const upKey = 38
const downKey = 40
const enterKey = 13
const navigationKeys = [upKey, downKey, enterKey]

export default class extends Controller {
  static classes = [ "current" ]
  static targets = [ "result" ]
  static outlets = [ "typeahead" ]

  connect() {
    this.currentResultIndex = 0

    const allElements = this.resultTarget.querySelectorAll(".search-result-item");

    allElements.forEach((element, index) => {
      element.addEventListener("click", () => {
        // Call the searchItemClicked member function when the element is clicked
        this.searchItemClicked(element, index);
      });
    })
    this.selectCurrentResult()
  }

  searchItemClicked(element, index) {
    const result_value = element.dataset.value;
    const result_id = element.dataset.id;

    // how to pass this to the search controller, set the field value and clear out the search
    console.log("search item clicked...", result_value, result_id)

    this.typeaheadOutlets.forEach(outlet => {
      outlet.hiddenFormValueTarget.value = result_id;
      outlet.queryTarget.value = result_value;
    })

    this.resultTarget.innerHTML = "";
  }

  navigateResults(event) {
    if(!navigationKeys.includes(event.keyCode)) {
      return
    }

    event.preventDefault()

    switch(event.keyCode) {
      case downKey:
        this.selectNextResult()
        break;
      case upKey:
        this.selectPreviousResult()
        break;
      case enterKey:
        this.goToSelectedResult()
        break;
    }
  }

  // private

  selectCurrentResult() {
    this.resultTargets.forEach((element, index) => {
      element.classList.toggle(this.currentClass, index == this.currentResultIndex)
    })
  }

  selectNextResult() {
    if(this.currentResultIndex < this.resultTargets.length - 1) {
      this.currentResultIndex++
      this.selectCurrentResult()
    }
  }

  selectPreviousResult() {
    if(this.currentResultIndex > 0) {
      this.currentResultIndex--
      this.selectCurrentResult()
    }
  }

  goToSelectedResult() {
    this.resultTargets[this.currentResultIndex].firstElementChild.click()
  }
}
