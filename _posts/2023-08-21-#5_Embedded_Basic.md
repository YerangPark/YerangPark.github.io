---
title: "[임베디드 기초] 5강 - 코드 분석하기"
date: 2023-09-25
categories: [Dev, Embedded]
tags: [embedded_basic]
render_with_liquid: false
---

## HAL 드라이버 분석하는 법
지난 시간에 HAL을 이용해서 뭘 했었냐면,
-  main()함수 내부에 HAL_Init() 함수를 호출하는 부분에 중단점을 찍었었다.
- 딜레이를 줄 때 HAL_Delay()함수로 딜레이를 주기도 했다.
- 핀을 제어할 때에는 HAL_GPIO_WritePin()을 이용해서 제어했었다.


이번 시간에는 HAL 드라이버에 의존하지 않고, **순수하게 내 코딩만으로 Write 기능을 구현**해보는 것이 목적이다.

임베디드는 코드는 몇 줄 안되지만, 내가 그 과정을 이해하고 코드로 표현하기까지는 수많은 시간이 필요하다. (알아야 될 지식이 참 많다...)


![](/assets/img/Embedded_Basic/05/1.png)

(알아만 두기) 우리 프로젝트는 Startup 디렉토리 하위에 있는 어셈블리 코드인 startup_stm32~.s 파일에서 시작한다.

<br>

# 코드 분석 시작!
## `HAL_Init()`의 `__HAL_FLASH_PREFETCH_BUFFER_ENABLE()`
![](/assets/img/Embedded_Basic/05/2.png)
- `PREFETCH_ENABLE`이 뭔진 모르겠지만, 값이 True이면서, `STM32F103xB`칩에 해당하므로 안쪽 defined 문에도 걸려서 `__HAL_FLASH_PREFETCH_BUFFER_ENABLE()` 함수를 실행하게 된다.
- `__HAL_FLASH_PREFETCH_BUFFER_ENABLE()` 함수 정의부는 아래와 같다.
    ```c
    #define __HAL_FLASH_PREFETCH_BUFFER_ENABLE()    (FLASH->ACR |= FLASH_ACR_PRFTBE)
    ```
    **😫 아~ 뭐라는거야~~**

- 잘 모르지만, 이대로 둘 순 없다. 우리는 IDE가 제공해주는 죠~은 기능을 활용하기 위해 (Ctrl+클릭)과 grep 대신 사용하는 (Ctrl+H)를 이용해서 쫓아갈 수 있다! 결과는 아래와 같다.
    ```c
    #define __HAL_FLASH_PREFETCH_BUFFER_ENABLE()    (FLASH->ACR |= FLASH_ACR_PRFTBE)
    #define FLASH               ((FLASH_TypeDef *)FLASH_R_BASE)
    #define FLASH_R_BASE          (AHBPERIPH_BASE + 0x00002000UL) /*!< Flash registers base address */
    #define AHBPERIPH_BASE        (PERIPH_BASE + 0x00020000UL)
    #define PERIPH_BASE           0x40000000UL /*!< Peripheral base address in the alias region */
    ```
    이걸 통해 알 수 있는 것은, 결과적으로 `FLASH`는 `0x40022000` 번지를 조작한다는 것이다.
- 근데, 이렇게 하나하나 트래킹하지 않더라도 값을 알 수 있는 방법이 있다!
    ![](/assets/img/Embedded_Basic/05/3.png)
    디버깅 모드일 때 탭에서 Expressions탭에서 식을 입력하면 값을 알 수 있다!!

- 그렇다면, `FLASH->ACR`이란?
    ![](/assets/img/Embedded_Basic/05/4.png)
    주소값을 찍어보니 위에 FLASH와 동일하다.
- 그럼, `FLASH_ACR_PRFTBE`이란? 16!
    ![](/assets/img/Embedded_Basic/05/5.png)
- 찾은 값을 대입 하면 아래와 같다.
  ```plainText
  *(40022000) |= 16;
  *(40022000) = *(40022000) | 16;
  ```
- `#define FLASH ((FLASH_TypeDef *)FLASH_R_BASE)` 문장에서 쓰인 FLASH_TypeDef 정의부를 보면 구조체 내용이 아래와 같다.
    ```c
    /** 
    * @brief FLASH Registers
    */

    typedef struct
    {
    __IO uint32_t ACR;
    __IO uint32_t KEYR;
    __IO uint32_t OPTKEYR;
    __IO uint32_t SR;
    __IO uint32_t CR;
    __IO uint32_t AR;
    __IO uint32_t RESERVED;
    __IO uint32_t OBR;
    __IO uint32_t WRPR;
    } FLASH_TypeDef;
    ```
    FLASH의 주소가 `0x40022000`이지만 `0`이라고 가정했을 때, (10진수 기준)
    - **0번지 : ACR 세팅 번지**
    - 4번지 : KEYR 세팅 번지
    - 8번지 : OPTKEYR 세팅 번지
    - 12번지 : SR
    - 16번지 : CR
    - 20번지 : AR
    - 24번지 : RESERVED
    - 28번지 : OBR
    - 32번지 : WRPR
    그러므로, FLASH->ACR을 하면 0번지에 접근이 된다.
- 추후, FLASH의 OBR에 4값의 세팅이 필요하다 하면, `FLASH->OBR|=4`를 이용하면 된다.
- FLASH의 실 주소인 `0x40022000` 기준으로 번지수를 다시 정리해보면
    - 4002200**0**번지 : `FLASH->ACR`
    - 4002200**4**번지 : `FLASH->KEYR`
    - 4002200**8**번지 : `FLASH->OPTKEYR`
    - 400220**0c**번지 : `FLASH->SR`
    - 400220**10**번지 : `FLASH->CR`
    - 400220**14**번지 : `FLASH->AR`
    - 400220**18**번지 : `FLASH->RESERVED`
    - 400220**1C**번지 : `FLASH->OBR`
    - 400220**20**번지 : `FLASH->WRPR`
- `#define __IO volatile`란? 최적화를 방지하는 용도의 키워드.
  
  **최적화를 왜 방지해??** 🙄

  최적화는 컴파일러가 한다. `int a = 3; a = 7; a = 3; a = 12;` 이런 코드가 있다고 해보자.   `printf("%d\n",a);`로 출력했을 때, 우리 똑똑이 컴파일러는 `int a = 12;` 로 줄여서 생각해버린다.

  그런데, GPIO를 제어한다고 생각해보자.

  `*a=0x03; a|=1; a|=0; a|=1; a|=0;` 이런 식으로 제어를 했다고 치자.
  우리 헛똑똑이(?) 컴파일러는 `*a=0x03; *a=0;`만 놔두고 나머지 수행을 빼버린다.

  또 이런 경우도 있다.
  `a=3; while() {if (a) { ... }}`이런 코드에서 a는 3일 수 밖에 었으니, `if (3) { ... }`이렇게 바꿔버리는 것이다!
  임베디드에서는 최적화 방지가 필요하다.
  
### 분석한 코드 정리
`(FLASH->ACR|=FLASH_ACR_PRFTBE)`는 아래와 같다.
```c
volatile unsigned int *reg = 40022000;
*reg |= 16;
```
- 여기서 16은 왜 16이야?
  - `FLASH_ACR_PRFTBE`를 따라가보면 `(0x1UL << 4U)`를 의미한다.
  - U는 unsigned를 의미한다. 그러니까 `1<<4`와 같다. 1을 옆으로 4칸 밀면 0001 0000이므로, 10진수로 16이라는 값을 가지게 된다.


<br>

## 데이터 시트와 연동해서 보자.
데이터 시트에서 ACR을 한 번 검색해보자.
![](/assets/img/Embedded_Basic/05/6.png)
- 구조체가 왜 그렇게 짜여져있는지, 데이터 시트에 적힌 구성과 함께 보면 이해된다!

좀 더 넘기다 보면...
![](/assets/img/Embedded_Basic/05/7.png)
- ACR의 역할에 대해서도 설명해주고 있다.
- 프리페치를 on/off하고, 메모리 액세스 시간 제어할 때 사용하나보다~ 정도 이해하고 넘어가자.

또 넘기다 보면
![](/assets/img/Embedded_Basic/05/8.png)
- ACR의 약자도 알게된다! Access Control Register였구나!
- 아까 우리가 `1<<4`연산을 했었는데, 그 연산을 똑같이 해보면, 하늘색 표시한 `PRFTBE`가 그에 해당한다.
- 그리고 그 `PRFTBE`는 프리패치 버퍼를 활/비활성화하는 역할을 한다.

<br>

## 결론적으로 이 코드가 의미하는 것은
플래시 메모리의 프리패치 기능을 활성화 했다.
각 부품마다 속도가 다른데,
CPU가 가장 빠르고 그 외에 레지스터, 램, 하드디스크, 이런 애들도 있다.

CPU <-> Register <-> RAM <-> HardDiskDrive <-> FlashMemory(SSD)

윈도우라는 것은 하드디스크에 저장되고,
전원을 누르는 순간 하드디스크에 있는 메모리가 램으로 올라온다.
그리고, 자주 사용되는 것은 CPU 내부의 레지스터에 등록해서 사용한다.
cpu와 램에 접근하는 것이 선이 몇가닥이냐에 따라서 32bit..이런 비트가 결정된다.


램과 하드디스크 간에는 굉장히 속도가 느리다.
우리는 추가로 플래쉬 메모리를 사용하는데, 이건 속도를 보완하기 위해서 사용한다.
플래쉬 메모리에 있는 무언가를 가져와서 빨리 돌리게 하기 위한 기능이 프리패치구나~라고 이해할 수 있다.

<br>

## 컴퓨터 배경지식이 중요하다.
위에 설명한 구조에 대해서 텍스트 파일을 열고, 편집하는 과정을 정리해 둘테니 참고하자.
<details>
<summary>텍스트 파일 편집 과정</summary>

    1. 사용자가 텍스트 편집 프로그램을 실행하면, 운영 체제는 하드디스크에서 해당 프로그램의 실행 파일을 찾아와 RAM으로 복사함.

    2. CPU는 RAM에 있는 텍스트 편집 프로그램의 명령어를 실행하여 프로그램을 시작하고, 필요한 계산을 수행함.

    3. 사용자가 편집하려는 텍스트 파일을 열면, 하드디스크에서 파일을 읽어와 RAM으로 로드(파일 내용 임시로 저장)함.
    
    4. 사용자가 텍스트를 편집하면, RAM에 있는 데이터가 레지스터로 이동하여 계산 및 편집 작업이 수행됨.

    5. 사용자가 저장 버튼을 클릭하면, 수정된 텍스트 데이터가 다시 RAM으로 이동하고, 이후 하드디스크 또는 플래시 메모리에 저장됨.
    
    6. 텍스트 편집 작업이 완료되면, CPU는 프로그램을 종료하고 RAM에 저장된 데이터를 정리(사용한 메모리 공간 해제)함.
    
    정리하자면, CPU는 중앙에서 모든 명령을 제어하고 데이터를 처리하는 핵심 역할을 하며, 하드디스크와 RAM은 데이터의 저장과 임시 보관을 담당하고, 레지스터는 중간 결과를 저장하는 데 사용된다.

</details>
