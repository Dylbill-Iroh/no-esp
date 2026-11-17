#pragma once

#include "RE/Skyrim.h"
#include "SKSE/SKSE.h"

// The xmake build of CommonLibSSE-NG logs through std::format (SPDLOG_USE_STD_FORMAT), which has no formatter
// for RE::BSFixedString (the old vcpkg build used fmt, which CommonLib has one for). Delete this if a newer
// CommonLibSSE-NG adds its own and it fails as a duplicate.
#include <format>
template <>
struct std::formatter<RE::BSFixedString, char> : std::formatter<std::string_view, char>
{
	template <class FormatContext>
	auto format(const RE::BSFixedString& a_str, FormatContext& a_ctx) const
	{
		const char* p = a_str.c_str();
		return std::formatter<std::string_view, char>::format(p ? std::string_view{ p } : std::string_view{}, a_ctx);
	}
};

#include <algorithm>
#include <array>
#include <atomic>
#include <bitset>
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <functional>
#include <initializer_list>
#include <limits>
#include <memory>
#include <mutex>
#include <optional>
#include <set>
#include <span>
#include <string>
#include <string_view>
#include <thread>
#include <tuple>
#include <type_traits>
#include <typeinfo>
#include <utility>
#include <variant>
#include <vector>

#pragma warning(push)
#include <spdlog/sinks/basic_file_sink.h>

#ifdef NDEBUG
#	include <spdlog/sinks/basic_file_sink.h>
#else
#	include <spdlog/sinks/msvc_sink.h>
#endif
#pragma warning(pop)

namespace logger = SKSE::log;

using namespace std::literals;

namespace stl {
	using namespace SKSE::stl;
	constexpr std::string_view safe_string(const char* a_str) { return a_str ? a_str : ""sv; }
}

#define DLLEXPORT __declspec(dllexport)
