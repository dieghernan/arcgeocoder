# message_api_call formats endpoint, parameters and encoded URL

    Code
      message_api_call(url)
    Message
      Request endpoint: https://example.com/search?
      Request parameters:
         - text=Main Street
         - limit=1
      Encoded URL: https://example.com/search?text=Main%20Street&limit=1

# input_multi validates structured address input

    Code
      input_multi()
    Condition
      Error in `input_multi()`:
      ! Provide at least one address component that is not `NA` or `NULL`.

---

    Code
      input_multi("a", c("a", "b"))
    Condition
      Error in `input_multi()`:
      ! All supplied address components must have the same length.

