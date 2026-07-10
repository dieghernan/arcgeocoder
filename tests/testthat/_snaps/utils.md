# message_api_call formats endpoint, parameters and encoded URL

    Code
      message_api_call(url)
    Message
      
      Endpoint: https://example.com/search?
      Parameters:
         - text=Main Street
         - limit=1
      URL: https://example.com/search?text=Main%20Street&limit=1

# input_multi validates structured address input

    Code
      input_multi()
    Condition
      Error in `input_multi()`:
      ! Provide at least one address component that is not `NA`.

---

    Code
      input_multi("a", c("a", "b"))
    Condition
      Error in `input_multi()`:
      ! When providing multiple address components, their lengths must be the same.

