function helper(toEncode) {
  // Block helper call
  if (typeof toEncode.fn === 'function') {
    return encodeURIComponent(toEncode.fn(this));
  }

  return encodeURIComponent(toEncode);
}

module.exports = helper;
