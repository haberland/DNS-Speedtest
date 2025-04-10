*** Settings ***
Library    Process
Library    OperatingSystem
Library    Collections
Library    String

*** Variables ***
${CSV_FILE}         results.csv
${URL_FILE}         urls.txt
${DNS_FILE}         server.txt

${TopTime}    10000
${TopServer}
${TopURL}

*** Test Cases ***
Measure DNS Resolution Times
    ${url_text}=    Get File    ${URL_FILE}
    ${dns_text}=    Get File    ${DNS_FILE}

    ${URLS}=    Split String    ${url_text}    \n
    ${DNS_SERVERS}=    Split String    ${dns_text}    \n

    Remove File    ${CSV_FILE}
    Create File    ${CSV_FILE}    dns_server,url,resolution_time_ms\n

    FOR    ${dns}    IN    @{DNS_SERVERS}
        FOR    ${url}    IN    @{URLS}
            ${code}=    Set Variable    import time; import dns.resolver; start = time.time(); r = dns.resolver.Resolver(); r.nameservers = ['${dns}']; r.resolve('${url}'); end = time.time(); print(round((end - start) * 1000, 2))
            ${result}=    Run Process    python3    -c    ${code}    shell=True    stdout=TRUE
            ${duration}=    Set Variable    ${result.stdout.strip()}

            ${duration} =    Evaluate    float(${duration})
            ${TopTime} =     Evaluate    float(${TopTime})
            IF  ${duration} >= 1 and ${duration} <= ${TopTime}
                ${TopTime}=    Set Variable    ${duration}
                ${TopServer}=    Set Variable    ${dns}
                ${TopURL}=    Set Variable    ${url}
            END
            Append To File    ${CSV_FILE}    ${dns},${url},${duration}\n
        END
    END
    Log    DNS measurements saved to ${CSV_FILE}
    Log To Console    Top DNS server: ${TopServer} with URL: ${TopURL} took ${TopTime} ms
