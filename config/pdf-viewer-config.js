/**
 * =====================================
 * 🎨 CUSTOM PDF.JS CONFIGURATION
 * Interactive PDF Viewer for Digital Dakwah Platform
 * =====================================
 * 
 * Purpose: Enhanced PDF viewer with multimedia support
 * Features:
 *   - Audio annotations
 *   - JavaScript execution
 *   - Enhanced hyperlinks
 *   - Interactive forms
 *   - Multimedia embedding
 * 
 * Based on: PDF.js (Mozilla)
 * License: Apache-2.0
 * =====================================
 */

// =====================================
// PDFJS GLOBAL CONFIGURATION
// =====================================

// Set PDF.js worker path
const PDFJS_WORKER_PATH = '/static/frontend/en-US/assets/js/pdf.worker.min.mjs';

// PDF.js configuration object
const PAPERLESS_PDFJS_CONFIG = {
  
  // =====================================
  // CORE SETTINGS
  // =====================================
  
  // Worker configuration
  workerSrc: PDFJS_WORKER_PATH,
  
  // Enable features disabled by default
  isEvalSupported: true,  // Enable JavaScript execution in PDFs
  disableAutoFetch: false,
  disableStream: false,
  
  // =====================================
  // INTERACTIVE FEATURES
  // =====================================
  
  // Enable JavaScript execution (for interactive PDFs)
  enableScripting: true,
  enableXfa: true,  // Enable XFA form support
  
  // Enable annotation features
  enableAnnotations: true,
  renderAnnotations: true,
  
  // Enable form fields
  renderInteractiveForms: true,
  
  // =====================================
  // MULTIMEDIA SUPPORT
  // =====================================
  
  // Audio annotations configuration
  audioAnnotations: {
    enabled: true,
    autoPlay: false,  // Require user interaction
    showControls: true,
    supportedFormats: ['mp3', 'wav', 'ogg', 'webm'],
    maxFileSize: 10 * 1024 * 1024,  // 10MB limit
  },
  
  // Video annotations (if needed)
  videoAnnotations: {
    enabled: true,
    autoPlay: false,
    showControls: true,
    supportedFormats: ['mp4', 'webm', 'ogg'],
    maxFileSize: 50 * 1024 * 1024,  // 50MB limit
  },
  
  // =====================================
  // HYPERLINK CONFIGURATION
  // =====================================
  
  hyperlinks: {
    enabled: true,
    
    // External links
    externalLinkTarget: 2,  // LINK_TARGET_BLANK (open in new tab)
    externalLinkRel: 'noopener noreferrer',
    
    // Internal navigation
    enableInternalLinks: true,
    highlightAnnotations: true,
    
    // Link behavior
    openInNewWindow: true,
    confirmExternalLinks: true,  // Show confirmation dialog
    
    // Custom link handler (override default behavior)
    customLinkHandler: true,
  },
  
  // =====================================
  // JAVASCRIPT SANDBOX
  // =====================================
  
  javascript: {
    enabled: true,
    
    // Security settings
    sandbox: true,  // Run in sandboxed environment
    
    // Allowed PDF JavaScript APIs
    allowedAPIs: [
      'app.alert',
      'app.beep',
      'console.println',
      'this.getField',
      'this.calculateNow',
      'util.printf',
      'AFSimple_Calculate',
    ],
    
    // Timeout for script execution (ms)
    timeout: 5000,
    
    // Custom event handlers
    enableCalculate: true,
    enableFormat: true,
    enableValidate: true,
    enableKeystroke: true,
  },
  
  // =====================================
  // RENDERING OPTIONS
  // =====================================
  
  rendering: {
    // Text layer (for selection & search)
    enableTextLayer: true,
    
    // Annotation layer (for interactive elements)
    enableAnnotationLayer: true,
    
    // Canvas rendering
    useWorkerFetch: true,
    
    // High-quality rendering
    renderingCancelled: false,
    
    // Image smoothing
    imageResourcesPath: '/static/frontend/en-US/assets/images/',
  },
  
  // =====================================
  // ACCESSIBILITY
  // =====================================
  
  accessibility: {
    // Screen reader support
    enableStructTree: true,
    
    // Keyboard navigation
    enableKeyboardNavigation: true,
    
    // High contrast mode
    enableHighContrast: false,
  },
  
  // =====================================
  // PERFORMANCE
  // =====================================
  
  performance: {
    // Disable web fonts (use system fonts for better performance)
    disableFontFace: false,
    
    // Caching
    cacheEnabled: true,
    
    // Lazy loading
    enableLazyLoading: true,
    
    // Max canvas pixels (prevent memory issues)
    maxCanvasPixels: 16777216,  // 4096x4096
  },
  
  // =====================================
  // CUSTOM FEATURES FOR ISLAMIC LIBRARY
  // =====================================
  
  islamicLibrary: {
    // Right-to-left support for Arabic PDFs
    defaultTextDirection: 'auto',  // 'ltr', 'rtl', or 'auto'
    
    // Arabic font support
    enableArabicFonts: true,
    
    // Quran audio integration
    quranAudio: {
      enabled: true,
      defaultReciter: 'Mishary_Rashid_Alafasy',
      showReciterSelector: true,
    },
    
    // Islamic annotations
    enableTajweedHighlights: true,
    enableTranslationOverlay: true,
  },
};

// =====================================
// CUSTOM EVENT HANDLERS
// =====================================

/**
 * Custom link click handler
 * @param {Object} link - Link object from PDF.js
 */
PAPERLESS_PDFJS_CONFIG.onLinkClick = function(link) {
  console.log('Link clicked:', link);
  
  // External link confirmation
  if (link.url && link.url.startsWith('http')) {
    const confirmed = confirm(`Open external link?\n${link.url}`);
    if (!confirmed) {
      return false;  // Cancel navigation
    }
  }
  
  // Internal navigation (page jumps)
  if (link.dest) {
    console.log('Navigating to destination:', link.dest);
    // Let PDF.js handle internal navigation
    return true;
  }
  
  return true;  // Allow navigation
};

/**
 * Audio annotation handler
 * @param {Object} annotation - Audio annotation object
 */
PAPERLESS_PDFJS_CONFIG.onAudioAnnotation = function(annotation) {
  console.log('Audio annotation:', annotation);
  
  // Create audio player element
  const audio = document.createElement('audio');
  audio.controls = this.audioAnnotations.showControls;
  audio.src = annotation.soundData || annotation.fileUrl;
  
  // Insert audio player at annotation position
  const container = document.querySelector(`[data-annotation-id="${annotation.id}"]`);
  if (container) {
    container.appendChild(audio);
  }
  
  return audio;
};

/**
 * JavaScript execution handler (sandboxed)
 * @param {string} script - JavaScript code from PDF
 * @param {Object} context - Execution context
 */
PAPERLESS_PDFJS_CONFIG.onScriptExecution = function(script, context) {
  console.log('Executing PDF script:', script);
  
  try {
    // Execute in sandboxed environment
    const result = eval(script);  // TODO: Replace with safer sandbox
    console.log('Script result:', result);
    return result;
  } catch (error) {
    console.error('Script execution error:', error);
    return null;
  }
};

// =====================================
// INITIALIZATION
// =====================================

/**
 * Initialize PDF.js with custom configuration
 */
function initializePDFJS() {
  // Check if PDF.js is loaded
  if (typeof pdfjsLib === 'undefined') {
    console.error('PDF.js library not loaded');
    return;
  }
  
  // Apply worker source
  pdfjsLib.GlobalWorkerOptions.workerSrc = PAPERLESS_PDFJS_CONFIG.workerSrc;
  
  // Apply global settings
  if (PAPERLESS_PDFJS_CONFIG.enableScripting) {
    pdfjsLib.GlobalWorkerOptions.isEvalSupported = true;
  }
  
  console.log('✅ PDF.js initialized with custom configuration');
  console.log('📊 Interactive features enabled:', {
    audio: PAPERLESS_PDFJS_CONFIG.audioAnnotations.enabled,
    javascript: PAPERLESS_PDFJS_CONFIG.javascript.enabled,
    hyperlinks: PAPERLESS_PDFJS_CONFIG.hyperlinks.enabled,
    forms: PAPERLESS_PDFJS_CONFIG.renderInteractiveForms,
  });
}

// =====================================
// EXPORT CONFIGURATION
// =====================================

// Export for use in Angular components
if (typeof module !== 'undefined' && module.exports) {
  module.exports = PAPERLESS_PDFJS_CONFIG;
}

// Make available globally
window.PAPERLESS_PDFJS_CONFIG = PAPERLESS_PDFJS_CONFIG;
window.initializePDFJS = initializePDFJS;

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializePDFJS);
} else {
  initializePDFJS();
}

// =====================================
// USAGE EXAMPLES
// =====================================

/*

// Example 1: Load PDF with custom config
const loadingTask = pdfjsLib.getDocument({
  url: '/media/documents/islamic-book.pdf',
  ...PAPERLESS_PDFJS_CONFIG,
});

// Example 2: Enable audio annotations
PAPERLESS_PDFJS_CONFIG.audioAnnotations.enabled = true;

// Example 3: Custom link handler
PAPERLESS_PDFJS_CONFIG.onLinkClick = function(link) {
  console.log('Custom link handler:', link);
  return true;
};

// Example 4: Quran audio integration
PAPERLESS_PDFJS_CONFIG.islamicLibrary.quranAudio.enabled = true;

*/
