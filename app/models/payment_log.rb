class PaymentLog < ActiveRecord::Base
  INFO = {1 => 'Profile created with status pending',
          '2' => 'Sending braintree S2S request',
          '3' => 'Got response from braintree transaction',
          '4' => 'Identifying missing transactions',
          '5' => 'Remote transaction was missing',
          '6' => 'Local transaction was missing',
          '7' => 'Responding by updating payment object',
          '8' => 'Doing transaction for failed payment',
          '9' => 'Last payment was success. Update the subscription to success payment',
  }

  LOG_LEVELS = {'1' => 'info', '2' => 'warn', '3' => 'error', '4' => 'fatal', ' 5' => 'debug'}

end
