# elm-amazon-product-advertising

Pure-Elm client of [Amazon Product Advertising API (PAAPI)][paapi].

[paapi]: https://docs.aws.amazon.com/AWSECommerceService/latest/DG/Welcome.html

Performs [AWS V2 signing][v2] for request authentication.

[v2]: http://docs.aws.amazon.com/AWSECommerceService/latest/DG/Query_QueryAuth.html

For decoding XML response, we use [ymtszw/elm-xml-decode][exd].

[exd]: http://package.elm-lang.org/packages/ymtszw/elm-xml-decode/latest

## Note on V2 signing

[AWS V2 signing][v2] is deprecated and no longer used for newly introduced AWS services.
PAAPI is the only remaining exception as far as I am aware.
For that I do not expose internal V2 signing functions since it should not have other use cases.

All existing AWS services in all regions should now accept V4 signing (or its S3 variation),
so you should use V4 signing when you are to implement clients for other services.
Pure-Elm V4 signing implementation is available in [ktonon/elm-aws-core][core].

[core]: http://package.elm-lang.org/packages/ktonon/elm-aws-core/latest
