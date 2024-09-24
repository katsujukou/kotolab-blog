/**
 * 
 * @param {Uint8Array} bytes 
 * @returns {Promise<ArrayBuffer>}
 */
export function digestSHA256Impl(bytes) {
  return crypto.subtle.digest("SHA-256", bytes);
}