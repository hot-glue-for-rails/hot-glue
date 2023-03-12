import Dropzone from "dropzone";
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    console.log("initializing dropzone controller")
    this.dropZone = this.createDropZone(this);
    this.hideFileInput();
    this.bindEvents();
    Dropzone.autoDiscover = false; // necessary quirk for Dropzone error in console
  }

  // helpers
  getMetaValue(name) {
    const element = this.findElement(document.head, `meta[name="${name}"]`);
    if (element) {
      return element.getAttribute("content");
    }
  }

  findElement(root, selector) {
    if (typeof root == "string") {
      selector = root;
      root = document;
    }
    return root.querySelector(selector);
  }

  toArray(value) {
    if (Array.isArray(value)) {
      return value;
    } else if (Array.from) {
      return Array.from(value);
    } else {
      return [].slice.call(value);
    }
  }


  hideFileInput() {
    this.inputTarget.disabled = true;
    this.inputTarget.style.display = "none";
  }

  bindEvents() {
    this.dropZone.on("addedfile", file => {
      setTimeout(() => {
        if (file.accepted) {
          const duc = new DirectUploadProcessor(this, this.url(), file)
          duc.start();
        }
      }, 500);
    });

    this.dropZone.on("removedfile", file => {
      if(file.controller) {
        file.controller.hiddenInput.parentNode.removeChild(file.controller.hiddenInput);
      }
    });

    this.dropZone.on("canceled", file => {
      file.controller && file.controller.xhr.abort();
    });
  }

  url() {
    return this.inputTarget.getAttribute("data-direct-upload-url");
  }

  createDropZone() {

    return new Dropzone(this.element, {
      url: this.url(),
      headers: this.headers,
      maxFiles: this.maxFiles,
      maxFilesize: this.maxFileSize,
      acceptedFiles: this.acceptedFiles,
      addRemoveLinks: this.addRemoveLinks,
      autoQueue: false
    });
  }

  get headers() {
    return { "X-CSRF-Token": this.getMetaValue("csrf-token") };
  }

  get maxFiles() {
    return this.data.get("maxFiles") || 1;
  }

  get maxFileSize() {
    return this.data.get("maxFileSize") || 256;
  }

  get acceptedFiles() {
    return this.data.get("acceptedFiles");
  }

  get addRemoveLinks() {
    return this.data.get("addRemoveLinks") || true;
  }
}

class DirectUploadProcessor {
  constructor(source, url, file) {
    this.directUpload = createDirectUpload(file, url, this);
    this.source = source;
    this.file = file;
    this.url = url;
  }

  insertAfter(el, referenceNode) {
    return referenceNode.parentNode.insertBefore(el, referenceNode.nextSibling);
  }

  start() {
    this.file.controller = this;
    this.hiddenInput = this.createHiddenInput();
    this.directUpload.create((error, attributes) => {
      if (error) {

        this.hiddenInput.remove();
        this.emitDropzoneError(error);
      } else {
        this.hiddenInput.value = attributes.signed_id;
        this.emitDropzoneSuccess();
      }
    });
  }

  createHiddenInput() {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = this.source.inputTarget.name;
    this.insertAfter(input, this.source.inputTarget);
    return input;
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr);
    this.emitDropzoneUploading();
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr;
    this.xhr.upload.addEventListener("progress", event =>
      this.uploadRequestDidProgress(event)
    );
  }

  findElement(root, selector) {
    if (typeof root == "string") {
      selector = root;
      root = document;
    }
    return root.querySelector(selector);
  }

  uploadRequestDidProgress(event) {
    const element = this.source.element;
    const progress = (event.loaded / event.total) * 100;
    this.findElement(
      this.file.previewTemplate,
      ".dz-upload"
    ).style.width = `${progress}%`;
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING;
    this.source.dropZone.emit("processing", this.file);
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR;
    this.source.dropZone.emit("error", this.file, error);
    this.source.dropZone.emit("complete", this.file);
  }

  emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS;
    this.source.dropZone.emit("success", this.file);
    this.source.dropZone.emit("complete", this.file);
  }
}


function createDirectUpload(file, url, controller) {
  return new DirectUpload(file, url, controller);
}

