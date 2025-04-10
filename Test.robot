*** Settings ***
Library    Process
Library    OperatingSystem
Library    Collections
Library    String

*** Variables ***
${DOMAIN}        netflix.com
${DNS_SERVER}    1.1.1.1

*** Test Cases ***
DNS Resolution Performance Test with Custom DNS Servers
    # Test mit Google-Domain
    ${duration} =    Resolve Domain With DNS    ${DOMAIN}    ${DNS_SERVER}
    Log To Console   \nResolution took ${duration} ms using DNS server ${DNS_SERVER}

    # Test mit System DNS
    ${duration} =    Resolve Domain With DNS    ${DOMAIN}    system
    Log To Console   \nResolution took ${duration} ms using system DNS

*** Keywords ***
Resolve Domain With DNS
    [Arguments]    ${domain}    ${dns_server}
    Flush DNS Cache
    IF     '${dns_server}' == 'system'
        ${start} =    Evaluate    time.time()    modules=time
        ${ip}=    Evaluate    __import__('socket').gethostbyname('${domain}')
        ${end} =    Evaluate    time.time()    modules=time
        ${duration_ms} =    Evaluate    round((${end} - ${start}) * 1000, 2)    # Zeit in Millisekunden berechnen
    ELSE
        ${code}=    Set Variable    import time; import dns.resolver; start = time.time(); r = dns.resolver.Resolver(); r.nameservers = ['${dns_server}']; r.resolve('${domain}'); end = time.time(); print(round((end - start) * 1000, 2))
        ${result}=    Run Process    python3    -c    ${code}    shell=True    stdout=TRUE
        ${duration_ms}=    Set Variable    ${result.stdout.strip()}
    END
    RETURN    ${duration_ms}

Resolve Domain With DNS 2
    [Arguments]    ${domain}    ${dns_server}
    ${code}=    Set Variable    import time; import dns.resolver; start = time.time(); r = dns.resolver.Resolver(); r.nameservers = ['${dns_server}']; r.resolve('${domain}'); end = time.time(); print(round((end - start) * 1000, 2))
    ${result}=    Run Process    python3    -c    ${code}    shell=True    #stdout=TRUE
    ${duration}=    Set Variable    ${result.stdout.strip()}
    RETURN    ${duration}

Flush DNS Cache
    Log To Console    message=\nFlushing DNS cache
    ${resolvers} =    Run Process    resolvectl flush-caches     shell=True    #stdout=TRUE
