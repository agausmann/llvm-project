//===-- runtime/dot-product.cpp -------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "cpp-type.h"
#include "descriptor.h"
#include "reduction.h"
#include "terminator.h"
#include "tools.h"
#include <cinttypes>

namespace Fortran::runtime {

template <typename ACCUMULATOR>
static inline auto DoDotProduct(const Descriptor &x, const Descriptor &y,
    Terminator &terminator) -> typename ACCUMULATOR::Result {
  RUNTIME_CHECK(terminator, x.rank() == 1 && y.rank() == 1);
  SubscriptValue n{x.GetDimension(0).Extent()};
  if (SubscriptValue yN{y.GetDimension(0).Extent()}; yN != n) {
    terminator.Crash(
        "DOT_PRODUCT: SIZE(VECTOR_A) is %jd but SIZE(VECTOR_B) is %jd",
        static_cast<std::intmax_t>(n), static_cast<std::intmax_t>(yN));
  }
  SubscriptValue xAt{x.GetDimension(0).LowerBound()};
  SubscriptValue yAt{y.GetDimension(0).LowerBound()};
  ACCUMULATOR accumulator{x, y};
  for (SubscriptValue j{0}; j < n; ++j) {
    accumulator.Accumulate(xAt++, yAt++);
  }
  return accumulator.GetResult();
}

template <TypeCategory RCAT, int RKIND,
    template <typename, TypeCategory, typename, typename> class ACCUM>
struct DotProduct {
  using Result = CppTypeFor<RCAT, RKIND>;
  template <TypeCategory XCAT, int XKIND> struct DP1 {
    template <TypeCategory YCAT, int YKIND> struct DP2 {
      Result operator()(const Descriptor &x, const Descriptor &y,
          Terminator &terminator) const {
        if constexpr (constexpr auto resultType{
                          GetResultType(XCAT, XKIND, YCAT, YKIND)}) {
          if constexpr (resultType->first == RCAT &&
              resultType->second <= RKIND) {
            using Accum = ACCUM<Result, XCAT, CppTypeFor<XCAT, XKIND>,
                CppTypeFor<YCAT, YKIND>>;
            return DoDotProduct<Accum>(x, y, terminator);
          }
        }
        terminator.Crash(
            "DOT_PRODUCT(%d(%d)): bad operand types (%d(%d), %d(%d))",
            static_cast<int>(RCAT), RKIND, static_cast<int>(XCAT), XKIND,
            static_cast<int>(YCAT), YKIND);
      }
    };
    Result operator()(const Descriptor &x, const Descriptor &y,
        Terminator &terminator, TypeCategory yCat, int yKind) const {
      return ApplyType<DP2, Result>(yCat, yKind, terminator, x, y, terminator);
    }
  };
  Result operator()(const Descriptor &x, const Descriptor &y,
      const char *source, int line) const {
    Terminator terminator{source, line};
    auto xCatKind{x.type().GetCategoryAndKind()};
    auto yCatKind{y.type().GetCategoryAndKind()};
    RUNTIME_CHECK(terminator, xCatKind.has_value() && yCatKind.has_value());
    return ApplyType<DP1, Result>(xCatKind->first, xCatKind->second, terminator,
        x, y, terminator, yCatKind->first, yCatKind->second);
  }
};

template <typename RESULT, TypeCategory XCAT, typename XT, typename YT>
class NumericAccumulator {
public:
  using Result = RESULT;
  NumericAccumulator(const Descriptor &x, const Descriptor &y) : x_{x}, y_{y} {}
  void Accumulate(SubscriptValue xAt, SubscriptValue yAt) {
    if constexpr (XCAT == TypeCategory::Complex) {
      sum_ += std::conj(static_cast<Result>(*x_.Element<XT>(&xAt))) *
          static_cast<Result>(*y_.Element<YT>(&yAt));
    } else {
      sum_ += static_cast<Result>(*x_.Element<XT>(&xAt)) *
          static_cast<Result>(*y_.Element<YT>(&yAt));
    }
  }
  Result GetResult() const { return sum_; }

private:
  const Descriptor &x_, &y_;
  Result sum_{0};
};

template <typename, TypeCategory, typename XT, typename YT>
class LogicalAccumulator {
public:
  using Result = bool;
  LogicalAccumulator(const Descriptor &x, const Descriptor &y) : x_{x}, y_{y} {}
  void Accumulate(SubscriptValue xAt, SubscriptValue yAt) {
    result_ = result_ ||
        (IsLogicalElementTrue(x_, &xAt) && IsLogicalElementTrue(y_, &yAt));
  }
  bool GetResult() const { return result_; }

private:
  const Descriptor &x_, &y_;
  bool result_{false};
};

extern "C" {
std::int8_t RTNAME(DotProductInteger1)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Integer, 8, NumericAccumulator>{}(
      x, y, source, line);
}
std::int16_t RTNAME(DotProductInteger2)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Integer, 8, NumericAccumulator>{}(
      x, y, source, line);
}
std::int32_t RTNAME(DotProductInteger4)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Integer, 8, NumericAccumulator>{}(
      x, y, source, line);
}
std::int64_t RTNAME(DotProductInteger8)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Integer, 8, NumericAccumulator>{}(
      x, y, source, line);
}
#ifdef __SIZEOF_INT128__
common::int128_t RTNAME(DotProductInteger16)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Integer, 16, NumericAccumulator>{}(
      x, y, source, line);
}
#endif

// TODO: REAL/COMPLEX(2 & 3)
float RTNAME(DotProductReal4)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Real, 8, NumericAccumulator>{}(
      x, y, source, line);
}
double RTNAME(DotProductReal8)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Real, 8, NumericAccumulator>{}(
      x, y, source, line);
}
#if LONG_DOUBLE == 80
long double RTNAME(DotProductReal10)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Real, 10, NumericAccumulator>{}(
      x, y, source, line);
}
#elif LONG_DOUBLE == 128
long double RTNAME(DotProductReal16)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Real, 16, NumericAccumulator>{}(
      x, y, source, line);
}
#endif

void RTNAME(CppDotProductComplex4)(std::complex<float> &result,
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  auto z{DotProduct<TypeCategory::Complex, 8, NumericAccumulator>{}(
      x, y, source, line)};
  result = std::complex<float>{
      static_cast<float>(z.real()), static_cast<float>(z.imag())};
}
void RTNAME(CppDotProductComplex8)(std::complex<double> &result,
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  result = DotProduct<TypeCategory::Complex, 8, NumericAccumulator>{}(
      x, y, source, line);
}
#if LONG_DOUBLE == 80
void RTNAME(CppDotProductComplex10)(std::complex<long double> &result,
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  result = DotProduct<TypeCategory::Complex, 10, NumericAccumulator>{}(
      x, y, source, line);
}
#elif LONG_DOUBLE == 128
void RTNAME(CppDotProductComplex16)(std::complex<long double> &result,
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  result = DotProduct<TypeCategory::Complex, 16, NumericAccumulator>{}(
      x, y, source, line);
}
#endif

bool RTNAME(DotProductLogical)(
    const Descriptor &x, const Descriptor &y, const char *source, int line) {
  return DotProduct<TypeCategory::Logical, 1, LogicalAccumulator>{}(
      x, y, source, line);
}
} // extern "C"
} // namespace Fortran::runtime
