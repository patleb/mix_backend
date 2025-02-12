#ifndef Rice__stl__hpp_
#define Rice__stl__hpp_


// =========   exception.hpp   =========

namespace Rice::stl
{
  extern Class rb_cStlException;
}


// ---------   exception.ipp   ---------
#include <exception>

// Libraries sometime inherit custom exception objects from std::exception,
// so define it for Ruby if necessary
namespace Rice::stl
{
  inline Class rb_cStlException;

  inline void define_stl_exception()
  {
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");
    rb_cStlException = define_class_under<std::exception>(rb_mStd, "Exception", rb_eStandardError).
                        define_constructor(Constructor<std::exception>()).
                        define_method("message", &std::exception::what);
  }
}

namespace Rice::detail
{
  template<>
  struct Type<std::exception>
  {
    static bool verify()
    {
      Rice::stl::define_stl_exception();
      return true;
    }
  };
}


// =========   exception_ptr.hpp   =========


// ---------   exception_ptr.ipp   ---------
#include <functional>

namespace Rice::stl
{
  inline Data_Type<std::exception_ptr> define_exception_ptr()
  {
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");

    return define_class_under<std::exception_ptr>(rb_mStd, "ExceptionPtr");
  }
}

namespace Rice::detail
{
  template<>
  struct Type<std::exception_ptr>
  {
    static bool verify()
    {
      if (!detail::Registries::instance.types.isDefined<std::exception_ptr>())
      {
        stl::define_exception_ptr();
      }

      return true;
    }
  };
}


// =========   string.hpp   =========


// ---------   string.ipp   ---------
namespace Rice::detail
{
  template<>
  struct Type<std::string>
  {
    static bool verify()
    {
      return true;
    }
  };

  template<>
  class To_Ruby<std::string>
  {
  public:
    VALUE convert(std::string const& x)
    {
      return detail::protect(rb_external_str_new, x.data(), (long)x.size());
    }
  };

  template<>
  class To_Ruby<std::string&>
  {
  public:
    VALUE convert(std::string const& x)
    {
      return detail::protect(rb_external_str_new, x.data(), (long)x.size());
    }
  };

  template<>
  class From_Ruby<std::string>
  {
  public:
    From_Ruby() = default;

    explicit From_Ruby(Arg* arg) : arg_(arg)
    {
    }

    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_STRING:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::string convert(VALUE value)
    {
      if (value == Qnil && this->arg_ && this->arg_->hasDefaultValue())
      {
        return this->arg_->defaultValue<std::string>();
      }
      else
      {
        detail::protect(rb_check_type, value, (int)T_STRING);
        return std::string(RSTRING_PTR(value), RSTRING_LEN(value));
      }
    }

  private:
    Arg* arg_ = nullptr;
  };

  template<>
  class From_Ruby<std::string&>
  {
  public:
    From_Ruby() = default;

    explicit From_Ruby(Arg* arg) : arg_(arg)
    {
    }

    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_STRING:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::string& convert(VALUE value)
    {
      if (value == Qnil && this->arg_ && this->arg_->hasDefaultValue())
      {
        return this->arg_->defaultValue<std::string>();
      }
      else
      {
        detail::protect(rb_check_type, value, (int)T_STRING);
        this->converted_ = std::string(RSTRING_PTR(value), RSTRING_LEN(value));
        return this->converted_;
      }
    }

  private:
    Arg* arg_ = nullptr;
    std::string converted_;
  };

  template<>
  class From_Ruby<std::string*>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_STRING:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::string* convert(VALUE value)
    {
      detail::protect(rb_check_type, value, (int)T_STRING);
      this->converted_ = std::string(RSTRING_PTR(value), RSTRING_LEN(value));
      return &this->converted_;
    }

  private:
    std::string converted_;
  };

  template<>
  class From_Ruby<std::string*&>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_STRING:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::string* convert(VALUE value)
    {
      detail::protect(rb_check_type, value, (int)T_STRING);
      this->converted_ = std::string(RSTRING_PTR(value), RSTRING_LEN(value));
      return &this->converted_;
    }

  private:
    std::string converted_;
  };
}

// =========   string_view.hpp   =========


// ---------   string_view.ipp   ---------
#include <string_view>

namespace Rice::detail
{
  template<>
  struct Type<std::string_view>
  {
    static bool verify()
    {
      return true;
    }
  };

  template<>
  class To_Ruby<std::string_view>
  {
  public:
    VALUE convert(std::string_view const& x)
    {
      return detail::protect(rb_external_str_new, x.data(), (long)x.size());
    }
  };

  template<>
  class To_Ruby<std::string_view&>
  {
  public:
    VALUE convert(std::string_view const& x)
    {
      return detail::protect(rb_external_str_new, x.data(), (long)x.size());
    }
  };

  template<>
  class From_Ruby<std::string_view>
  {
  public:
    From_Ruby() = default;

    explicit From_Ruby(Arg* arg) : arg_(arg)
    {
    }

    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_STRING:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::string_view convert(VALUE value)
    {
      if (value == Qnil && this->arg_ && this->arg_->hasDefaultValue())
      {
        return this->arg_->defaultValue<std::string_view>();
      }
      else
      {
        detail::protect(rb_check_type, value, (int)T_STRING);
        return std::string_view(RSTRING_PTR(value), RSTRING_LEN(value));
      }
    }

  private:
    Arg* arg_ = nullptr;
  };
}

// =========   complex.hpp   =========


// ---------   complex.ipp   ---------
#include <complex>


namespace Rice::detail
{
  template<typename T>
  struct Type<std::complex<T>>
  {
    static bool verify()
    {
      return true;
    }
  };

  template<typename T>
  class To_Ruby<std::complex<T>>
  {
  public:
    VALUE convert(const std::complex<T>& data)
    {
      std::vector<VALUE> args(2);
      args[0] = To_Ruby<T>().convert(data.real());
      args[1] = To_Ruby<T>().convert(data.imag());
      return protect(rb_funcallv, rb_mKernel, rb_intern("Complex"), (int)args.size(), (const VALUE*)args.data());
    }
  };

  template<typename T>
  class From_Ruby<std::complex<T>>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_COMPLEX:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::complex<T> convert(VALUE value)
    {
      VALUE real = protect(rb_funcallv, value, rb_intern("real"), 0, (const VALUE*)nullptr);
      VALUE imaginary = protect(rb_funcallv, value, rb_intern("imaginary"), 0, (const VALUE*)nullptr);

      return std::complex<T>(From_Ruby<T>().convert(real), From_Ruby<T>().convert(imaginary));
    }
  };

  template<typename T>
  class From_Ruby<std::complex<T>&>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_COMPLEX:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::complex<T>& convert(VALUE value)
    {
      VALUE real = protect(rb_funcallv, value, rb_intern("real"), 0, (const VALUE*)nullptr);
      VALUE imaginary = protect(rb_funcallv, value, rb_intern("imaginary"), 0, (const VALUE*)nullptr);
      this->converted_ = std::complex<T>(From_Ruby<T>().convert(real), From_Ruby<T>().convert(imaginary));

      return this->converted_;
    }

  private:
    std::complex<T> converted_;
  };
}


// =========   optional.hpp   =========


// ---------   optional.ipp   ---------
#include <optional>

namespace Rice::detail
{
  template<typename T>
  struct Type<std::optional<T>>
  {
    constexpr static bool verify()
    {
      return Type<intrinsic_type<T>>::verify();
    }
  };

  template<>
  class To_Ruby<std::nullopt_t>
  {
  public:
    VALUE convert(std::nullopt_t& _)
    {
      return Qnil;
    }
  };

  template<typename T>
  class To_Ruby<std::optional<T>>
  {
  public:
    static VALUE convert(const std::optional<T>& data, bool takeOwnership = false)
    {
      if (data.has_value())
      {
        return To_Ruby<T>().convert(data.value());
      }
      else
      {
        return Qnil;
      }
    }
  };

  template<typename T>
  class To_Ruby<std::optional<T>&>
  {
  public:
    static VALUE convert(const std::optional<T>& data, bool takeOwnership = false)
    {
      if (data.has_value())
      {
        return To_Ruby<T>().convert(data.value());
      }
      else
      {
        return Qnil;
      }
    }
  };

  template<typename T>
  class From_Ruby<std::optional<T>>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_NIL:
          return Convertible::Exact;
          break;
        default:
          return From_Ruby<T>().is_convertible(value);
      }
    }

    std::optional<T> convert(VALUE value)
    {
      if (value == Qnil)
      {
        return std::nullopt;
      }
      else
      {
        return From_Ruby<T>().convert(value);
      }
    }
  };

  template<typename T>
  class From_Ruby<std::optional<T>&>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      switch (rb_type(value))
      {
        case RUBY_T_NIL:
          return Convertible::Exact;
          break;
        default:
          return From_Ruby<T>().is_convertible(value);
      }
    }

    std::optional<T>& convert(VALUE value)
    {
      if (value == Qnil)
      {
        this->converted_ = std::nullopt;
      }
      else
      {
        this->converted_ = From_Ruby<T>().convert(value);
      }
      return this->converted_;
    }
  private:
    std::optional<T> converted_;
  };
}


// =========   reference_wrapper.hpp   =========


// ---------   reference_wrapper.ipp   ---------
#include <functional>

namespace Rice::detail
{
  template<typename T>
  struct Type<std::reference_wrapper<T>>
  {
    constexpr static bool verify()
    {
      return Type<T>::verify();
    }
  };

  template<typename T>
  class To_Ruby<std::reference_wrapper<T>>
  {
  public:
    VALUE convert(const std::reference_wrapper<T>& data, bool takeOwnership = false)
    {
      return To_Ruby<T&>().convert(data.get());
    }
  };

  template<typename T>
  class From_Ruby<std::reference_wrapper<T>>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      return this->converter_.is_convertible(value);
    }

    std::reference_wrapper<T> convert(VALUE value)
    {
      return this->converter_.convert(value);
    }

  private:
    From_Ruby<T&> converter_;
  };
}


// =========   smart_ptr.hpp   =========


namespace Rice::detail
{
  template <template <typename, typename...> typename SmartPointer_T, typename...Arg_Ts>
  class WrapperSmartPointer : public Wrapper
  {
  public:
    WrapperSmartPointer(SmartPointer_T<Arg_Ts...> data);
    ~WrapperSmartPointer();
    void* get() override;
    SmartPointer_T<Arg_Ts...>& data();

  private:
    SmartPointer_T<Arg_Ts...> data_;
  };
}


// ---------   smart_ptr.ipp   ---------

#include <assert.h>
#include <memory>

namespace Rice::detail
{
  // ---- WrapperSmartPointer ------
  template <template <typename, typename...> typename SmartPointer_T, typename...Arg_Ts>
  inline WrapperSmartPointer<SmartPointer_T, Arg_Ts...>::WrapperSmartPointer(SmartPointer_T<Arg_Ts...> data) 
    : data_(std::move(data))
  {
  }

  template <template <typename, typename...> typename SmartPointer_T, typename...Arg_Ts>
  inline WrapperSmartPointer<SmartPointer_T, Arg_Ts...>::~WrapperSmartPointer()
  {
    Registries::instance.instances.remove(this->get());
  }

  template <template <typename, typename...> typename SmartPointer_T, typename...Arg_Ts>
  inline void* WrapperSmartPointer<SmartPointer_T, Arg_Ts...>::get()
  {
    return (void*)this->data_.get();
  }

  template <template <typename, typename...> typename SmartPointer_T, typename...Arg_Ts>
  inline SmartPointer_T<Arg_Ts...>& WrapperSmartPointer<SmartPointer_T, Arg_Ts...>::data()
  {
    return data_;
  }

  // ---- unique_ptr ------
  template <typename T>
  class To_Ruby<std::unique_ptr<T>>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::unique_ptr, T>;

    VALUE convert(std::unique_ptr<T>& data)
    {
      std::pair<VALUE, rb_data_type_t*> rubyTypeInfo = detail::Registries::instance.types.figureType<T>(*data);
      return detail::wrap<std::unique_ptr<T>, Wrapper_T>(rubyTypeInfo.first, rubyTypeInfo.second, data, true);
    }
  };

  template <typename T>
  class To_Ruby<std::unique_ptr<T>&>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::unique_ptr, T>;

    VALUE convert(std::unique_ptr<T>& data)
    {
      std::pair<VALUE, rb_data_type_t*> rubyTypeInfo = detail::Registries::instance.types.figureType<T>(*data);
      return detail::wrap<std::unique_ptr<T>, Wrapper_T>(rubyTypeInfo.first, rubyTypeInfo.second, data, true);
    }
  };

  template <typename T>
  class From_Ruby<std::unique_ptr<T>>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::unique_ptr, T>;

    Wrapper_T* is_same_smart_ptr(VALUE value)
    {
      Wrapper* wrapper = detail::getWrapper(value, Data_Type<T>::ruby_data_type());
      return dynamic_cast<Wrapper_T*>(wrapper);
    }

    Convertible is_convertible(VALUE value)
    {
      if (!is_same_smart_ptr(value))
        return Convertible::None;

      switch (rb_type(value))
      {
        case RUBY_T_DATA:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::unique_ptr<T> convert(VALUE value)
    {
      Wrapper_T* smartWrapper = is_same_smart_ptr(value);
      if (!smartWrapper)
      {
        std::string message = "Invalid smart pointer wrapper";
        throw std::runtime_error(message.c_str());
      }
      return std::move(smartWrapper->data());
    }
  };

  template <typename T>
  class From_Ruby<std::unique_ptr<T>&>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::unique_ptr, T>;

    Wrapper_T* is_same_smart_ptr(VALUE value)
    {
      Wrapper* wrapper = detail::getWrapper(value, Data_Type<T>::ruby_data_type());
      return dynamic_cast<Wrapper_T*>(wrapper);
    }

    Convertible is_convertible(VALUE value)
    {
      if (!is_same_smart_ptr(value))
        return Convertible::None;

      switch (rb_type(value))
      {
        case RUBY_T_DATA:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::unique_ptr<T>& convert(VALUE value)
    {
      Wrapper_T* smartWrapper = is_same_smart_ptr(value);
      if (!smartWrapper)
      {
        std::string message = "Invalid smart pointer wrapper";
        throw std::runtime_error(message.c_str());
      }
      return smartWrapper->data();
    }
  };

  template<typename T>
  struct Type<std::unique_ptr<T>>
  {
    static bool verify()
    {
      return Type<T>::verify();
    }
  };

  // ----- shared_ptr -------------
  template <typename T>
  class To_Ruby<std::shared_ptr<T>>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::shared_ptr, T>;

    VALUE convert(std::shared_ptr<T>& data)
    {
      std::pair<VALUE, rb_data_type_t*> rubyTypeInfo = detail::Registries::instance.types.figureType<T>(*data);
      return detail::wrap<std::shared_ptr<T>, Wrapper_T>(rubyTypeInfo.first, rubyTypeInfo.second, data, true);
    }
  };

  template <>
  class To_Ruby<std::shared_ptr<void>>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::shared_ptr, void>;

    VALUE convert(std::shared_ptr<void>& data)
    {
      std::pair<VALUE, rb_data_type_t*> rubyTypeInfo = detail::Registries::instance.types.figureType(data.get());
      return detail::wrap<std::shared_ptr<void>, Wrapper_T>(rubyTypeInfo.first, rubyTypeInfo.second, data, true);
    }
  };

  template <typename T>
  class From_Ruby<std::shared_ptr<T>>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::shared_ptr, T>;

    From_Ruby() = default;

    explicit From_Ruby(Arg * arg) : arg_(arg)
    {
    }

    Wrapper_T* is_same_smart_ptr(VALUE value)
    {
      Wrapper* wrapper = detail::getWrapper(value, Data_Type<T>::ruby_data_type());
      return dynamic_cast<Wrapper_T*>(wrapper);
    }

    Convertible is_convertible(VALUE value)
    {
      if (!is_same_smart_ptr(value))
        return Convertible::None;

      switch (rb_type(value))
      {
        case RUBY_T_DATA:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::shared_ptr<T> convert(VALUE value)
    {
      if(value == Qnil && this->arg_ && this->arg_->hasDefaultValue()) {
        return this->arg_->template defaultValue<std::shared_ptr<T>>();
      }

      Wrapper_T* smartWrapper = is_same_smart_ptr(value);
      if (!smartWrapper)
      {
        std::string message = "Invalid smart pointer wrapper";
          throw std::runtime_error(message.c_str());
      }
      return smartWrapper->data();
    }
  private:
    Arg* arg_ = nullptr;
  };

  template <typename T>
  class To_Ruby<std::shared_ptr<T>&>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::shared_ptr, T>;

    VALUE convert(std::shared_ptr<T>& data)
    {
      std::pair<VALUE, rb_data_type_t*> rubyTypeInfo = detail::Registries::instance.types.figureType<T>(*data);
      return detail::wrap<std::shared_ptr<T>, Wrapper_T>(rubyTypeInfo.first, rubyTypeInfo.second, data, true);
    }
  };

  template <typename T>
  class From_Ruby<std::shared_ptr<T>&>
  {
  public:
    using Wrapper_T = WrapperSmartPointer<std::shared_ptr, T>;

    From_Ruby() = default;

    explicit From_Ruby(Arg * arg) : arg_(arg)
    {
    }

    Wrapper_T* is_same_smart_ptr(VALUE value)
    {
      Wrapper* wrapper = detail::getWrapper(value, Data_Type<T>::ruby_data_type());
      return dynamic_cast<Wrapper_T*>(wrapper);
    }

    Convertible is_convertible(VALUE value)
    {
      if (!is_same_smart_ptr(value))
        return Convertible::None;

      switch (rb_type(value))
      {
        case RUBY_T_DATA:
          return Convertible::Exact;
          break;
        default:
          return Convertible::None;
      }
    }

    std::shared_ptr<T>& convert(VALUE value)
    {
      if(value == Qnil && this->arg_ && this->arg_->hasDefaultValue()) {
        return this->arg_->template defaultValue<std::shared_ptr<T>>();
      }

      Wrapper_T* smartWrapper = is_same_smart_ptr(value);
      if (!smartWrapper)
      {
        std::string message = "Invalid smart pointer wrapper";
          throw std::runtime_error(message.c_str());
      }
      return smartWrapper->data();
    }

  private:
    Arg* arg_ = nullptr;
  };

  template<typename T>
  struct Type<std::shared_ptr<T>>
  {
    static bool verify()
    {
      return Type<T>::verify();
    }
  };
}


// =========   monostate.hpp   =========


// ---------   monostate.ipp   ---------
#include <variant>

namespace Rice::detail
{
  template<>
  struct Type<std::monostate>
  {
    constexpr static bool verify()
    {
      return true;
    }
  };

  template<>
  class To_Ruby<std::monostate>
  {
  public:
    VALUE convert(const std::monostate& _)
    {
      return Qnil;
    }
  };

  template<>
  class To_Ruby<std::monostate&>
  {
  public:
    static VALUE convert(const std::monostate& data, bool takeOwnership = false)
    {
      return Qnil;
    }
  };

  template<>
  class From_Ruby<std::monostate>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      return Convertible::None;
    }

    std::monostate convert(VALUE value)
    {
      return std::monostate();
    }
  };

  template<>
  class From_Ruby<std::monostate&>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      return Convertible::None;
    }

    std::monostate& convert(VALUE value)
    {
      return this->converted_;
    }
    
  private:
    std::monostate converted_ = std::monostate();
  };
}


// =========   type_index.hpp   =========


// ---------   type_index.ipp   ---------
#include <typeindex>

namespace Rice::stl
{
  inline Data_Type<std::type_index> define_type_index()
  {
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");

    return define_class_under<std::type_index>(rb_mStd, "TypeIndex").
      define_constructor(Constructor<std::type_index, const std::type_info&>()).
      define_method("hash_code", &std::type_index::hash_code).
      define_method("name", &std::type_index::name);
  }
}

namespace Rice::detail
{
  template<>
  struct Type<std::type_index>
  {
    static bool verify()
    {
      if (!detail::Registries::instance.types.isDefined<std::type_index>())
      {
        stl::define_type_index();
      }

      return true;
    }
  };
}


// =========   type_info.hpp   =========


// ---------   type_info.ipp   ---------
#include <typeinfo>

namespace Rice::stl
{
  inline Data_Type<std::type_info> define_type_info()
  {
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");

    return define_class_under<std::type_info>(rb_mStd, "TypeInfo").
      define_method("hash_code", &std::type_info::hash_code).
      define_method("name", &std::type_info::name);
  }
}

namespace Rice::detail
{
  template<>
  struct Type<std::type_info>
  {
    static inline bool verify()
    {
      if (!detail::Registries::instance.types.isDefined<std::type_info>())
      {
        stl::define_type_info();
      }

      return true;
    }
  };
}


// =========   variant.hpp   =========


// ---------   variant.ipp   ---------
#include <variant>

namespace Rice::detail
{
  template<typename...Types>
  struct Type<std::variant<Types...>>
  {
    using Tuple_T = std::tuple<Types...>;

    template<std::size_t... I>
    constexpr static bool verifyTypes(std::index_sequence<I...>& indices)
    {
      return (Type<std::tuple_element_t<I, Tuple_T>>::verify() && ...);
    }

    template<std::size_t... I>
    constexpr static bool verify()
    {
      auto indices = std::make_index_sequence<std::variant_size_v<std::variant<Types...>>>{};
      return verifyTypes(indices);
    }
  };

  template<typename...Types>
  class To_Ruby<std::variant<Types...>>
  {
  public:

    template<typename T>
    static VALUE convertElement(const std::variant<Types...>& data, bool takeOwnership)
    {
      return To_Ruby<T>().convert(std::get<T>(data));
    }

    template<std::size_t... I>
    static VALUE convertIterator(const std::variant<Types...>& data, bool takeOwnership, std::index_sequence<I...>& indices)
    {
      // Create a tuple of the variant types so we can look over the tuple's types
      using Tuple_T = std::tuple<Types...>;
      
      /* This is a fold expression. In pseudo code:
       
        for (type in variant.types)
        {
          if (variant.has_value<type>())
            return ToRuby<type>().convert(variant.getValue<type>)
        }

        The list of variant types is stored in Tuple_T. The number of types is stored in I.
        Starting with index 0, get the variant type using td::tuple_element_t<I, Tuple_T>>.
        Next check if the variant has a value for that type using std::holds_alternative<T>. 
        If yes, then call convertElement and save the return value to result. Then use the 
        comma operator to return true to the fold expression. If the variant does not have
        a value for the type then return false. 
        
        The fold operator is or (||). If an index returns false, then the next index is evaluated
        up until I. 
        
        Code inspired by https://www.foonathan.net/2020/05/fold-tricks/ */

      VALUE result = Qnil;

      #if defined(__GNUC__) || defined(__clang__)
      #pragma GCC diagnostic push
      #pragma GCC diagnostic ignored "-Wunused-value"
      #endif

      ((std::holds_alternative<std::tuple_element_t<I, Tuple_T>>(data) ?
               (result = convertElement<std::tuple_element_t<I, Tuple_T>>(data, takeOwnership), true) : false) || ...);
      
      #if defined(__GNUC__) || defined(__clang__)
      #pragma GCC diagnostic pop
      #endif

      return result;
    }

    static VALUE convert(const std::variant<Types...>& data, bool takeOwnership = false)
    {
      auto indices = std::make_index_sequence<std::variant_size_v<std::variant<Types...>>>{};
      return convertIterator(data, takeOwnership, indices);
    }
  };

  template<typename...Types>
  class To_Ruby<std::variant<Types...>&>
  {
  public:
    template<typename T>
    static VALUE convertElement(const std::variant<Types...>& data, bool takeOwnership)
    {
      return To_Ruby<T>().convert(std::get<T>(data));
    }

    template<std::size_t... I>
    static VALUE convertIterator(const std::variant<Types...>& data, bool takeOwnership, std::index_sequence<I...>& indices)
    {
      // Create a tuple of the variant types so we can look over the tuple's types
      using Tuple_T = std::tuple<Types...>;

      // See comments above for explanation of this code
      VALUE result = Qnil;

      #if defined(__GNUC__) || defined(__clang__)
      #pragma GCC diagnostic push
      #pragma GCC diagnostic ignored "-Wunused-value"
      #endif

      ((std::holds_alternative<std::tuple_element_t<I, Tuple_T>>(data) ?
        (result = convertElement<std::tuple_element_t<I, Tuple_T>>(data, takeOwnership), true) : false) || ...);

      #if defined(__GNUC__) || defined(__clang__)
      #pragma GCC diagnostic pop
      #endif

      return result;
    }

    static VALUE convert(const std::variant<Types...>& data, bool takeOwnership = false)
    {
      auto indices = std::make_index_sequence<std::variant_size_v<std::variant<Types...>>>{};
      return convertIterator(data, takeOwnership, indices);
    }
  };

  template<typename...Types>
  class From_Ruby<std::variant<Types...>>
  {
  public:
    Convertible is_convertible(VALUE value)
    {
      Convertible result = Convertible::None;

      for_each_tuple(this->fromRubys_,
        [&](auto& fromRuby)
        {
          result = result | fromRuby.is_convertible(value);
        });

      return result;
    }

    // This method search through a variant's types to figure out which one the
    // currently Ruby value best matches. It then returns the index of the type.
    int figureIndex(VALUE value)
    {
      int i = 0;
      int index = -1;
      Convertible foundConversion = Convertible::None;

      for_each_tuple(this->fromRubys_,
        [&](auto& fromRuby)
        {
          Convertible isConvertible = fromRuby.is_convertible(value);

          if (isConvertible > foundConversion)
          {
            index = i;
            foundConversion = isConvertible;
          }
          i++;
        });

      if (index == -1)
      {
        rb_raise(rb_eArgError, "Could not find converter for variant");
      }

      return index;
    }

    /* This method loops over each type in the variant, creates a From_Ruby converter,
       and then check if the converter can work with the provided Rby value (it checks
       the type of the Ruby object to see if it matches the variant type).
       If yes, then the converter runs. If no, then the method recursively calls itself
       increasing the index.

       We use recursion, with a constexpr, to avoid having to instantiate an instance
       of the variant to store results from a fold expression like the To_Ruby code
       does above. That allows us to process variants with non default constructible
       arguments like std::reference_wrapper. */
    template <std::size_t I = 0>
    std::variant<Types...> convertInternal(VALUE value, int index)
    {
      if constexpr (I < std::variant_size_v<std::variant<Types...>>)
      {
        if (I == index)
        {
          auto fromRuby = std::get<I>(this->fromRubys_);
          return fromRuby.convert(value);
        }
        else
        {
          return convertInternal<I + 1>(value, index);
        }
      }
      rb_raise(rb_eArgError, "Could not find converter for variant");
    }

    std::variant<Types...> convert(VALUE value)
    {
      int index = this->figureIndex(value);
      return this->convertInternal(value, index);
    }

  private:
    // Possible converters we could use for this variant
    using From_Ruby_Ts = std::tuple<From_Ruby<Types>...>;
    From_Ruby_Ts fromRubys_;
  };

  template<typename...Types>
  class From_Ruby<std::variant<Types...>&> : public From_Ruby<std::variant<Types...>>
  {
  public:
    std::variant<Types...>& convert(VALUE value)
    {
      int index = this->figureIndex(value);
      this->converted_ = this->convertInternal(value, index);
      return this->converted_;
    }

  private:
    std::variant<Types...> converted_;
  };
}


// =========   pair.hpp   =========


namespace Rice
{
  template<typename T>
  Data_Type<T> define_pair(std::string name);

  template<typename T>
  Data_Type<T> define_pair_under(Object parent, std::string name);
}


// ---------   pair.ipp   ---------

#include <sstream>
#include <stdexcept>
#include <utility>

namespace Rice
{
  namespace stl
  {
    template<typename T>
    class PairHelper
    {
    public:
      PairHelper(Data_Type<T> klass) : klass_(klass)
      {
        this->define_constructor();
        this->define_copyable_methods();
        this->define_access_methods();
        this->define_modify_methods();
        this->define_to_s();
      }

    private:
      void define_constructor()
      {
        klass_.define_constructor(Constructor<T, typename T::first_type&, typename T::second_type&>());
      }

      void define_copyable_methods()
      {
        if constexpr (std::is_copy_constructible_v<typename T::first_type> && std::is_copy_constructible_v<typename T::second_type>)
        {
          klass_.define_method("copy", [](T& pair) -> T
            {
              return pair;
            });
        }
        else
        {
          klass_.define_method("copy", [](T& pair) -> T
            {
              throw std::runtime_error("Cannot copy pair with non-copy constructible types");
              return pair;
            });
        }
      }

      void define_access_methods()
      {
        // Access methods
        klass_.define_method("first", [](T& pair) -> typename T::first_type&
          {
            return pair.first;
          })
        .define_method("second", [](T& pair) -> typename T::second_type&
          {
            return pair.second;
          });
      }

      void define_modify_methods()
      {
        // Access methods
        klass_.define_method("first=", [](T& pair, typename T::first_type& value) -> typename T::first_type&
        {
          if constexpr (std::is_const_v<std::remove_reference_t<std::remove_pointer_t<typename T::first_type>>>)
          {
            throw std::runtime_error("Cannot set pair.first since it is a constant");
          }
          else
          {
            pair.first = value;
            return pair.first;
          }
        })
        .define_method("second=", [](T& pair, typename T::second_type& value) -> typename T::second_type&
        {
          if constexpr (std::is_const_v<std::remove_reference_t<std::remove_pointer_t<typename T::second_type>>>)
          {
            throw std::runtime_error("Cannot set pair.second since it is a constant");
          }
          else
          {
            pair.second = value;
            return pair.second;
          }
        });
      }

      void define_to_s()
      {
        if constexpr (detail::is_ostreamable_v<typename T::first_type> && detail::is_ostreamable_v<typename T::second_type>)
        {
          klass_.define_method("to_s", [](const T& pair)
            {
              std::stringstream stream;
              stream << "[" << pair.first << ", " << pair.second << "]";
              return stream.str();
            });
        }
        else
        {
          klass_.define_method("to_s", [](const T& pair)
            {
              return "[Not printable]";
            });
        }
      }

      private:
        Data_Type<T> klass_;
    };
  } // namespace

  template<typename T>
  Data_Type<T> define_pair_under(Object parent, std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the pair has been previously seen it will be registered but may
      // not be associated with the constant Module::<name>
      parent.const_set_maybe(name, Data_Type<T>().klass());
      return Data_Type<T>();
    }

    Data_Type<T> result = define_class_under<detail::intrinsic_type<T>>(parent, name.c_str());
    stl::PairHelper helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_pair(std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the pair has been previously seen it will be registered but may
      // not be associated with the constant Object::<name>
      Object(rb_cObject).const_set_maybe(name, Data_Type<T>().klass());
      return Data_Type<T>();
    }

    Data_Type<T> result = define_class<detail::intrinsic_type<T>>(name.c_str());
    stl::PairHelper<T> helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_pair_auto()
  {
    std::string name = detail::typeName(typeid(T));
    std::string klassName = detail::makeClassName(name);
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");
    return define_pair_under<T>(rb_mStd, klassName);
  }
   
  namespace detail
  {
    template<typename T1, typename T2>
    struct Type<std::pair<T1, T2>>
    {
      static bool verify()
      {
        detail::verifyType<T1>();
        detail::verifyType<T2>();

        if (!detail::Registries::instance.types.isDefined<std::pair<T1, T2>>())
        {
          define_pair_auto<std::pair<T1, T2>>();
        }

        return true;
      }
    };
  }
}



// =========   map.hpp   =========


namespace Rice
{
  template<typename U>
  Data_Type<U> define_map(std::string name);

  template<typename U>
  Data_Type<U> define_map_under(Object module, std::string name);
}


// ---------   map.ipp   ---------

#include <sstream>
#include <stdexcept>
#include <map>
#include <type_traits>
#include <variant>

namespace Rice
{
  namespace stl
  {
    template<typename T>
    class MapHelper
    {
      using Key_T = typename T::key_type;
      using Mapped_T = typename T::mapped_type;
      using Value_T = typename T::value_type;
      using Reference_T = typename T::reference;
      using Size_T = typename T::size_type;
      using Difference_T = typename T::difference_type;
      using To_Ruby_T = typename detail::remove_cv_recursive_t<Mapped_T>;

    public:
      MapHelper(Data_Type<T> klass) : klass_(klass)
      {
        this->register_pair();
        this->define_constructor();
        this->define_copyable_methods();
        this->define_capacity_methods();
        this->define_access_methods();
        this->define_comparable_methods();
        this->define_modify_methods();
        this->define_enumerable();
        this->define_to_s();
        this->define_to_hash();
      }

    private:

      void register_pair()
      {
        define_pair_auto<Value_T>();
      }

      void define_constructor()
      {
        klass_.define_constructor(Constructor<T>());
      }

      void define_copyable_methods()
      {
        if constexpr (std::is_copy_constructible_v<Value_T>)
        {
          klass_.define_method("copy", [](T& map) -> T
            {
              return map;
            });
        }
        else
        {
          klass_.define_method("copy", [](T& map) -> T
            {
              throw std::runtime_error("Cannot copy maps with non-copy constructible types");
              return map;
            });
        }
      }

      void define_capacity_methods()
      {
        klass_.define_method("empty?", &T::empty)
          .define_method("max_size", &T::max_size)
          .define_method("size", &T::size);
        
        rb_define_alias(klass_, "count", "size");
        rb_define_alias(klass_, "length", "size");
      }

      void define_access_methods()
      {
        // Access methods
        klass_.define_method("[]", [](const T& map, const Key_T& key) -> std::optional<Mapped_T>
          {
            auto iter = map.find(key);

            if (iter != map.end())
            {
              return iter->second;
            }
            else
            {
              return std::nullopt;
            }
          })
          .define_method("include?", [](T& map, Key_T& key) -> bool
          {
              return map.find(key) != map.end();
          })
          .define_method("keys", [](T& map) -> std::vector<Key_T>
            {
              std::vector<Key_T> result;
              std::transform(map.begin(), map.end(), std::back_inserter(result),
                [](const auto& pair)
                {
                  return pair.first;
                });

              return result;
            })
          .define_method("values", [](T& map) -> std::vector<Mapped_T>
            {
              std::vector<Mapped_T> result;
              std::transform(map.begin(), map.end(), std::back_inserter(result),
                [](const auto& pair)
                {
                  return pair.second;
                });

              return result;
            });

            rb_define_alias(klass_, "has_key", "include?");
      }

      // Methods that require Value_T to support operator==
      void define_comparable_methods()
      {
        if constexpr (detail::is_comparable_v<Mapped_T>)
        {
          klass_.define_method("value?", [](T& map, Mapped_T& value) -> bool
            {
              auto it = std::find_if(map.begin(), map.end(),
              [&value](auto& pair)
                {
                  return pair.second == value;
                });

              return it != map.end();
          });
        }
        else
        {
          klass_.define_method("value?", [](T& map, Mapped_T& value) -> bool
          {
              return false;
          });
        }

        rb_define_alias(klass_, "has_value", "value?");
      }

      void define_modify_methods()
      {
        klass_.define_method("clear", &T::clear)
          .define_method("delete", [](T& map, Key_T& key) -> std::optional<Mapped_T>
            {
              auto iter = map.find(key);

              if (iter != map.end())
              {
                Mapped_T result = iter->second;
                map.erase(iter);
                return result;
              }
              else
              {
                return std::nullopt;
              }
            })
          .define_method("[]=", [](T& map, Key_T key, Mapped_T& value) -> Mapped_T
            {
              map[key] = value;
              return value;
            });

          rb_define_alias(klass_, "store", "[]=");
      }

      void define_enumerable()
      {
        // Add enumerable support
        klass_.template define_iterator<typename T::iterator (T::*)()>(&T::begin, &T::end);
      }

      void define_to_hash()
      {
        // Add enumerable support
        klass_.define_method("to_h", [](T& map)
        {
          VALUE result = rb_hash_new();
          std::for_each(map.begin(), map.end(), [&result](const Reference_T pair)
          {
            VALUE key = detail::To_Ruby<Key_T&>().convert(pair.first);
            VALUE value = detail::To_Ruby<To_Ruby_T&>().convert(pair.second);
            rb_hash_aset(result, key, value);
          });

          return result;
        }, Return().setValue());
      }

      void define_to_s()
      {
        if constexpr (detail::is_ostreamable_v<Key_T> && detail::is_ostreamable_v<Mapped_T>)
        {
          klass_.define_method("to_s", [](const T& map)
            {
              auto iter = map.begin();

              std::stringstream stream;
              stream << "{";

              for (; iter != map.end(); iter++)
              {
                if (iter != map.begin())
                {
                  stream << ", ";
                }
                stream << iter->first << " => " << iter->second;
              }

              stream << "}";
              return stream.str();
            });
        }
        else
        {
          klass_.define_method("to_s", [](const T& map)
            {
              return "[Not printable]";
            });
        }
      }

      private:
        Data_Type<T> klass_;
    };
  } // namespace

  template<typename T>
  Data_Type<T> define_map_under(Object parent, std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the map has been previously seen it will be registered but may
      // not be associated with the constant Module::<name>
      parent.const_set_maybe(name, Data_Type<T>().klass());
      return Data_Type<T>();
    }

    Data_Type<T> result = define_class_under<detail::intrinsic_type<T>>(parent, name.c_str());
    stl::MapHelper helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_map(std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the map has been previously seen it will be registered but may
      // not be associated with the constant Object::<name>
      Object(rb_cObject).const_set_maybe(name, Data_Type<T>().klass());
      return Data_Type<T>();
    }

    Data_Type<T> result = define_class<detail::intrinsic_type<T>>(name.c_str());
    stl::MapHelper<T> helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_map_auto()
  {
    std::string name = detail::typeName(typeid(T));
    std::string klassName = detail::makeClassName(name);
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");
    return define_map_under<T>(rb_mStd, klassName);
  }
   
  namespace detail
  {
    template<typename T, typename U>
    struct Type<std::map<T, U>>
    {
      static bool verify()
      {
        Type<T>::verify();
        Type<U>::verify();

        if (!detail::Registries::instance.types.isDefined<std::map<T, U>>())
        {
          define_map_auto<std::map<T, U>>();
        }

        return true;
      }
    };

    template<typename T, typename U>
    struct MapFromHash
    {
      static int convertPair(VALUE key, VALUE value, VALUE user_data)
      {
        std::map<T, U>* result = (std::map<T, U>*)(user_data);

        // This method is being called from Ruby so we cannot let any C++ 
        // exceptions propogate back to Ruby
        return cpp_protect([&]
        {
          result->operator[](From_Ruby<T>().convert(key)) = From_Ruby<U>().convert(value);
          return ST_CONTINUE;
        });
      }

      static std::map<T, U> convert(VALUE value)
      {
        std::map<T, U> result;
        VALUE user_data = (VALUE)(&result);

        // MSVC needs help here, but g++ does not
        using Rb_Hash_ForEach_T = void(*)(VALUE, int(*)(VALUE, VALUE, VALUE), VALUE);
        detail::protect<Rb_Hash_ForEach_T>(rb_hash_foreach, value, convertPair, user_data);

        return result;
      }
    };

    template<typename T, typename U>
    class From_Ruby<std::map<T, U>>
    {
    public:
      From_Ruby() = default;

      explicit From_Ruby(Arg * arg) : arg_(arg)
      {
      }

      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_HASH:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::map<T, U> convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped map (hopefully!)
            return *Data_Object<std::map<T, U>>::from_ruby(value);
          }
          case RUBY_T_HASH:
          {
            // If this an Ruby hash and the mapped type is copyable
            if constexpr (std::is_default_constructible_v<U>)
            {
              return MapFromHash<T, U>::convert(value);
            }
          }
          case RUBY_T_NIL:
          {
            if (this->arg_ && this->arg_->hasDefaultValue())
            {
              return this->arg_->template defaultValue<std::map<T, U>>();
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::map");
          }
        }
      }

    private:
      Arg* arg_ = nullptr;
    };

    template<typename T, typename U>
    class From_Ruby<std::map<T, U>&>
    {
    public:
      From_Ruby() = default;

      explicit From_Ruby(Arg * arg) : arg_(arg)
      {
      }

      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_HASH:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::map<T, U>& convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped map (hopefully!)
            return *Data_Object<std::map<T, U>>::from_ruby(value);
          }
          case RUBY_T_HASH:
          {
            // If this an Ruby array and the map type is copyable
            if constexpr (std::is_default_constructible_v<std::map<T, U>>)
            {
              this->converted_ = MapFromHash<T, U>::convert(value);
              return this->converted_;
            }
          }
          case RUBY_T_NIL:
          {
            if (this->arg_ && this->arg_->hasDefaultValue())
            {
              return this->arg_->template defaultValue<std::map<T, U>>();
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::map");
          }
        }
      }

    private:
      Arg* arg_ = nullptr;
      std::map<T, U> converted_;
    };

    template<typename T, typename U>
    class From_Ruby<std::map<T, U>*>
    {
    public:
      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_NIL:
            return Convertible::Exact;
            break;
          case RUBY_T_HASH:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::map<T, U>* convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped map (hopefully!)
            return Data_Object<std::map<T, U>>::from_ruby(value);
          }
          case RUBY_T_HASH:
          {
            // If this an Ruby array and the map type is copyable
            if constexpr (std::is_default_constructible_v<U>)
            {
              this->converted_ = MapFromHash<T, U>::convert(value);
              return &this->converted_;
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::map");
          }
        }
      }

    private:
      std::map<T, U> converted_;
    };
  }
}

// =========   unordered_map.hpp   =========


namespace Rice
{
  template<typename U>
  Data_Type<U> define_unordered_map(std::string name);

  template<typename U>
  Data_Type<U> define_unordered_map_under(Object parent, std::string name);
}


// ---------   unordered_map.ipp   ---------

#include <sstream>
#include <stdexcept>
#include <type_traits>
#include <unordered_map>
#include <variant>

namespace Rice
{
  namespace stl
  {
    template<typename T>
    class UnorderedMapHelper
    {
      using Key_T = typename T::key_type;
      using Mapped_T = typename T::mapped_type;
      using Value_T = typename T::value_type;
      using Reference_T = typename T::reference;
      using Size_T = typename T::size_type;
      using Difference_T = typename T::difference_type;
      using To_Ruby_T = typename detail::remove_cv_recursive_t<Mapped_T>;

    public:
      UnorderedMapHelper(Data_Type<T> klass) : klass_(klass)
      {
        this->register_pair();
        this->define_constructor();
        this->define_copyable_methods();
        this->define_capacity_methods();
        this->define_access_methods();
        this->define_comparable_methods();
        this->define_modify_methods();
        this->define_enumerable();
        this->define_to_s();
        this->define_to_hash();
      }

    private:

      void register_pair()
      {
        define_pair_auto<Value_T>();
      }

      void define_constructor()
      {
        klass_.define_constructor(Constructor<T>());
      }

      void define_copyable_methods()
      {
        if constexpr (std::is_copy_constructible_v<Value_T>)
        {
          klass_.define_method("copy", [](T& unordered_map) -> T
            {
              return unordered_map;
            });
        }
        else
        {
          klass_.define_method("copy", [](T& unordered_map) -> T
            {
              throw std::runtime_error("Cannot copy unordered_maps with non-copy constructible types");
              return unordered_map;
            });
        }
      }

      void define_capacity_methods()
      {
        klass_.define_method("empty?", &T::empty)
          .define_method("max_size", &T::max_size)
          .define_method("size", &T::size);
        
        rb_define_alias(klass_, "count", "size");
        rb_define_alias(klass_, "length", "size");
      }

      void define_access_methods()
      {
        // Access methods
        klass_.define_method("[]", [](const T& unordered_map, const Key_T& key) -> std::optional<Mapped_T>
          {
            auto iter = unordered_map.find(key);

            if (iter != unordered_map.end())
            {
              return iter->second;
            }
            else
            {
              return std::nullopt;
            }
          })
          .define_method("include?", [](T& unordered_map, Key_T& key) -> bool
          {
              return unordered_map.find(key) != unordered_map.end();
          })
          .define_method("keys", [](T& unordered_map) -> std::vector<Key_T>
            {
              std::vector<Key_T> result;
              std::transform(unordered_map.begin(), unordered_map.end(), std::back_inserter(result),
                [](const auto& pair)
                {
                  return pair.first;
                });

              return result;
            })
          .define_method("values", [](T& unordered_map) -> std::vector<Mapped_T>
            {
              std::vector<Mapped_T> result;
              std::transform(unordered_map.begin(), unordered_map.end(), std::back_inserter(result),
                [](const auto& pair)
                {
                  return pair.second;
                });

              return result;
            });

            rb_define_alias(klass_, "has_key", "include?");
      }

      // Methods that require Value_T to support operator==
      void define_comparable_methods()
      {
        if constexpr (detail::is_comparable_v<Mapped_T>)
        {
          klass_.define_method("value?", [](T& unordered_map, Mapped_T& value) -> bool
            {
              auto it = std::find_if(unordered_map.begin(), unordered_map.end(),
              [&value](auto& pair)
                {
                  return pair.second == value;
                });

              return it != unordered_map.end();
          });
        }
        else
        {
          klass_.define_method("value?", [](T& unordered_map, Mapped_T& value) -> bool
          {
              return false;
          });
        }

        rb_define_alias(klass_, "has_value", "value?");
      }

      void define_modify_methods()
      {
        klass_.define_method("clear", &T::clear)
          .define_method("delete", [](T& unordered_map, Key_T& key) -> std::optional<Mapped_T>
            {
              auto iter = unordered_map.find(key);

              if (iter != unordered_map.end())
              {
                Mapped_T result = iter->second;
                unordered_map.erase(iter);
                return result;
              }
              else
              {
                return std::nullopt;
              }
            })
          .define_method("[]=", [](T& unordered_map, Key_T key, Mapped_T& value) -> Mapped_T
            {
              unordered_map[key] = value;
              return value;
            });

          rb_define_alias(klass_, "store", "[]=");
      }

      void define_enumerable()
      {
        // Add enumerable support
        klass_.template define_iterator<typename T::iterator (T::*)()>(&T::begin, &T::end);
      }

      void define_to_hash()
      {
        // Add enumerable support
        klass_.define_method("to_h", [](T& unordered_map)
        {
          VALUE result = rb_hash_new();
          std::for_each(unordered_map.begin(), unordered_map.end(), [&result](const Reference_T& pair)
          {
            VALUE key = detail::To_Ruby<Key_T&>().convert(pair.first);
            VALUE value = detail::To_Ruby<To_Ruby_T&>().convert(pair.second);
            rb_hash_aset(result, key, value);
          });

          return result;
        }, Return().setValue());
      }

      void define_to_s()
      {
        if constexpr (detail::is_ostreamable_v<Key_T> && detail::is_ostreamable_v<Mapped_T>)
        {
          klass_.define_method("to_s", [](const T& unordered_map)
            {
              auto iter = unordered_map.begin();

              std::stringstream stream;
              stream << "{";

              for (; iter != unordered_map.end(); iter++)
              {
                if (iter != unordered_map.begin())
                {
                  stream << ", ";
                }
                stream << iter->first << " => " << iter->second;
              }

              stream << "}";
              return stream.str();
            });
        }
        else
        {
          klass_.define_method("to_s", [](const T& unordered_map)
            {
              return "[Not printable]";
            });
        }
      }

      private:
        Data_Type<T> klass_;
    };
  } // namespace

  template<typename T>
  Data_Type<T> define_unordered_map_under(Object parent, std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the unordered_map has been previously seen it will be registered but may
      // not be associated with the constant Module::<name>
      parent.const_set_maybe(name, Data_Type<T>().klass());
      return Data_Type<T>();
    }

    Data_Type<T> result = define_class_under<detail::intrinsic_type<T>>(parent, name.c_str());
    stl::UnorderedMapHelper helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_unordered_map(std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the unordered_map has been previously seen it will be registered but may
      // not be associated with the constant Object::<name>
      Object(rb_cObject).const_set_maybe(name, Data_Type<T>().klass());
      return Data_Type<T>();
    }

    Data_Type<T> result = define_class<detail::intrinsic_type<T>>(name.c_str());
    stl::UnorderedMapHelper<T> helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_unordered_map_auto()
  {
    std::string name = detail::typeName(typeid(T));
    std::string klassName = detail::makeClassName(name);
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");
    return define_unordered_map_under<T>(rb_mStd, klassName);
  }
   
  namespace detail
  {
    template<typename T, typename U>
    struct Type<std::unordered_map<T, U>>
    {
      static bool verify()
      {
        Type<T>::verify();
        Type<U>::verify();

        if (!detail::Registries::instance.types.isDefined<std::unordered_map<T, U>>())
        {
          define_unordered_map_auto<std::unordered_map<T, U>>();
        }

        return true;
      }
    };

    template<typename T, typename U>
    struct UnorderedMapFromHash
    {
      static int convertPair(VALUE key, VALUE value, VALUE user_data)
      {
        std::unordered_map<T, U>* result = (std::unordered_map<T, U>*)(user_data);

        // This method is being called from Ruby so we cannot let any C++ 
        // exceptions propogate back to Ruby
        return cpp_protect([&]
        {
          result->operator[](From_Ruby<T>().convert(key)) = From_Ruby<U>().convert(value);
          return ST_CONTINUE;
        });
      }

      static std::unordered_map<T, U> convert(VALUE value)
      {
        std::unordered_map<T, U> result;
        VALUE user_data = (VALUE)(&result);

        // MSVC needs help here, but g++ does not
        using Rb_Hash_ForEach_T = void(*)(VALUE, int(*)(VALUE, VALUE, VALUE), VALUE);
        detail::protect<Rb_Hash_ForEach_T>(rb_hash_foreach, value, convertPair, user_data);

        return result;
      }
    };

    template<typename T, typename U>
    class From_Ruby<std::unordered_map<T, U>>
    {
    public:
      From_Ruby() = default;

      explicit From_Ruby(Arg * arg) : arg_(arg)
      {
      }

      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_HASH:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::unordered_map<T, U> convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped unordered_map (hopefully!)
            return *Data_Object<std::unordered_map<T, U>>::from_ruby(value);
          }
          case RUBY_T_HASH:
          {
            // If this an Ruby hash and the unordered_mapped type is copyable
            if constexpr (std::is_default_constructible_v<U>)
            {
              return UnorderedMapFromHash<T, U>::convert(value);
            }
          }
          case RUBY_T_NIL:
          {
            if (this->arg_ && this->arg_->hasDefaultValue())
            {
              return this->arg_->template defaultValue<std::unordered_map<T, U>>();
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::unordered_map");
          }
        }
      }

    private:
      Arg* arg_ = nullptr;
    };

    template<typename T, typename U>
    class From_Ruby<std::unordered_map<T, U>&>
    {
    public:
      From_Ruby() = default;

      explicit From_Ruby(Arg * arg) : arg_(arg)
      {
      }

      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_HASH:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::unordered_map<T, U>& convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped unordered_map (hopefully!)
            return *Data_Object<std::unordered_map<T, U>>::from_ruby(value);
          }
          case RUBY_T_HASH:
          {
            // If this an Ruby array and the unordered_map type is copyable
            if constexpr (std::is_default_constructible_v<std::unordered_map<T, U>>)
            {
              this->converted_ = UnorderedMapFromHash<T, U>::convert(value);
              return this->converted_;
            }
          }
          case RUBY_T_NIL:
          {
            if (this->arg_ && this->arg_->hasDefaultValue())
            {
              return this->arg_->template defaultValue<std::unordered_map<T, U>>();
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::unordered_map");
          }
        }
      }

    private:
      Arg* arg_ = nullptr;
      std::unordered_map<T, U> converted_;
    };

    template<typename T, typename U>
    class From_Ruby<std::unordered_map<T, U>*>
    {
    public:
      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_NIL:
            return Convertible::Exact;
            break;
          case RUBY_T_HASH:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::unordered_map<T, U>* convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped unordered_map (hopefully!)
            return Data_Object<std::unordered_map<T, U>>::from_ruby(value);
          }
          case RUBY_T_HASH:
          {
            // If this an Ruby array and the unordered_map type is copyable
            if constexpr (std::is_default_constructible_v<U>)
            {
              this->converted_ = UnorderedMapFromHash<T, U>::convert(value);
              return &this->converted_;
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::unordered_map");
          }
        }
      }

    private:
      std::unordered_map<T, U> converted_;
    };
  }
}

// =========   vector.hpp   =========


namespace Rice
{
  template<typename T>
  Data_Type<T> define_vector(std::string name);

  template<typename T>
  Data_Type<T> define_vector_under(Object parent, std::string name);
}


// ---------   vector.ipp   ---------

#include <sstream>
#include <stdexcept>
#include <type_traits>
#include <vector>
#include <variant>

namespace Rice
{
  namespace stl
  {
    template<typename T>
    class VectorHelper
    {
      // We do NOT use Reference_T and instead use Parameter_T to avoid the weirdness
      // of std::vector<bool>. Reference_T is actually a proxy class that we do not
      // want to have to register with Rice nor do we want to pass it around.
      using Value_T = typename T::value_type;
      using Size_T = typename T::size_type;
      using Difference_T = typename T::difference_type;
      // For To_Ruby_T however we do need to use reference type because this is what
      // will be passed by an interator to To_Ruby#convert
      using Reference_T = typename T::reference;
      using Parameter_T = std::conditional_t<std::is_pointer_v<Value_T>, Value_T, Value_T&>;
      using To_Ruby_T = detail::remove_cv_recursive_t<typename T::reference>;

    public:
      VectorHelper(Data_Type<T> klass) : klass_(klass)
      {
        this->define_constructor();
        this->define_copyable_methods();
        this->define_constructable_methods();
        this->define_capacity_methods();
        this->define_access_methods();
        this->define_comparable_methods();
        this->define_modify_methods();
        this->define_enumerable();
        this->define_to_array();
        this->define_to_s();
      }

    private:

      // Helper method to translate Ruby indices to vector indices
      Difference_T normalizeIndex(Size_T size, Difference_T index, bool enforceBounds = false)
      {
        // Negative indices mean count from the right. Note that negative indices
        // wrap around!
        if (index < 0)
        {
          index = ((-index) % size);
          index = index > 0 ? size - index : index;
        }

        if (enforceBounds && (index < 0 || index >= (Difference_T)size))
        {
          throw std::out_of_range("Invalid index: " + std::to_string(index));
        }

        return index;
      };

      void define_constructor()
      {
        klass_.define_constructor(Constructor<T>());
      }

      void define_copyable_methods()
      {
        if constexpr (std::is_copy_constructible_v<Value_T>)
        {
          klass_.define_method("copy", [](T& vector) -> T
            {
              return vector;
            });
        }
        else
        {
          klass_.define_method("copy", [](T& vector) -> T
            {
              throw std::runtime_error("Cannot copy vectors with non-copy constructible types");
              return vector;
            });
        }
      }

      void define_constructable_methods()
      {
        if constexpr (std::is_default_constructible_v<Value_T> && std::is_same_v<Value_T, bool>)
        {
          klass_.define_method("resize", static_cast<void (T::*)(const size_t, bool)>(&T::resize));
        }
        else if constexpr (std::is_default_constructible_v<Value_T>)
        {
          klass_.define_method("resize", static_cast<void (T::*)(const size_t)>(&T::resize));
        }
        else
        {
          klass_.define_method("resize", [](const T& vector, Size_T newSize)
              {
                // Do nothing
              });
        }
      }

      void define_capacity_methods()
      {
        klass_.define_method("empty?", &T::empty)
          .define_method("capacity", &T::capacity)
          .define_method("max_size", &T::max_size)
          .define_method("reserve", &T::reserve)
          .define_method("size", &T::size);
        
        rb_define_alias(klass_, "count", "size");
        rb_define_alias(klass_, "length", "size");
        //detail::protect(rb_define_alias, klass_, "count", "size");
        //detail::protect(rb_define_alias, klass_, "length", "size");
      }

      void define_access_methods()
      {
        // Access methods
        klass_.define_method("first", [](const T& vector) -> std::optional<Value_T>
        {
          if (vector.size() > 0)
          {
            return vector.front();
          }
          else
          {
            return std::nullopt;
          }
        })
        .define_method("last", [](const T& vector) -> std::optional<Value_T>
          {
            if (vector.size() > 0)
            {
              return vector.back();
            }
            else
            {
              return std::nullopt;
            }
          })
        .define_method("[]", [this](const T& vector, Difference_T index) -> std::optional<Value_T>
          {
            index = normalizeIndex(vector.size(), index);
            if (index < 0 || index >= (Difference_T)vector.size())
            {
              return std::nullopt;
            }
            else
            {
              return vector[index];
            }
          })
        .define_method("[]", [this](const T& vector, Difference_T start, Difference_T length) -> VALUE
          {
            start = normalizeIndex(vector.size(), start);
            if (start < 0 || start >= (Difference_T)vector.size())
            {
              return rb_ary_new();
            }
            else
            {
              auto begin = vector.begin() + start;

              // Ruby does not throw an exception when the length is too long
              if (start + length > vector.size())
              {
                length = vector.size() - start;
              }

              auto finish = vector.begin() + start + length;
              T slice(begin, finish);

              VALUE result = rb_ary_new();
              std::for_each(slice.begin(), slice.end(), [&result](const Reference_T element)
              {
                VALUE value = detail::To_Ruby<Parameter_T>().convert(element);
                rb_ary_push(result, value);
              });

              return result;
            }
          }, Return().setValue());

          rb_define_alias(klass_, "at", "[]");
      }

      // Methods that require Value_T to support operator==
      void define_comparable_methods()
      {
        if constexpr (detail::is_comparable_v<Value_T>)
        {
          klass_.define_method("delete", [](T& vector, Parameter_T element) -> std::optional<Value_T>
            {
              auto iter = std::find(vector.begin(), vector.end(), element);
              if (iter == vector.end())
              {
                return std::nullopt;
              }
              else
              {
                Value_T result = *iter;
                vector.erase(iter);
                return result;
              }
            })
          .define_method("include?", [](T& vector, Parameter_T element)
            {
              return std::find(vector.begin(), vector.end(), element) != vector.end();
            })
          .define_method("index", [](T& vector, Parameter_T element) -> std::optional<Difference_T>
            {
              auto iter = std::find(vector.begin(), vector.end(), element);
              if (iter == vector.end())
              {
                return std::nullopt;
              }
              else
              {
                return iter - vector.begin();
              }
            });
        }
        else
        {
          klass_.define_method("delete", [](T& vector, Parameter_T element) -> std::optional<Value_T>
            {
              return std::nullopt;
            })
          .define_method("include?", [](const T& vector, Parameter_T element)
            {
              return false;
            })
          .define_method("index", [](const T& vector, Parameter_T element) -> std::optional<Difference_T>
            {
              return std::nullopt;
            });
        }
      }

      void define_modify_methods()
      {
        klass_.define_method("clear", &T::clear)
          .define_method("delete_at", [](T& vector, const size_t& pos)
            {
              auto iter = vector.begin() + pos;
              Value_T result = *iter;
              vector.erase(iter);
              return result;
            })
          .define_method("insert", [this](T& vector, Difference_T index, Parameter_T element) -> T&
            {
              index = normalizeIndex(vector.size(), index, true);
              auto iter = vector.begin() + index;
              vector.insert(iter, element);
              return vector;
            })
          .define_method("pop", [](T& vector) -> std::optional<Value_T>
            {
              if (vector.size() > 0)
              {
                Value_T result = vector.back();
                vector.pop_back();
                return result;
              }
              else
              {
                return std::nullopt;
              }
            })
          .define_method("push", [](T& vector, Parameter_T element) -> T&
            {
              vector.push_back(element);
              return vector;
            })
          .define_method("shrink_to_fit", &T::shrink_to_fit)
          .define_method("[]=", [this](T& vector, Difference_T index, Parameter_T element) -> Parameter_T
            {
              index = normalizeIndex(vector.size(), index, true);
              vector[index] = element;
              return element;
            });

            rb_define_alias(klass_, "<<", "push");
            rb_define_alias(klass_, "append", "push");
      }

      void define_enumerable()
      {
        // Add enumerable support
        klass_.template define_iterator<typename T::iterator(T::*)()>(&T::begin, &T::end);
      }

      void define_to_array()
      {
        // Add enumerable support
        klass_.define_method("to_a", [](T& vector)
        {
          VALUE result = rb_ary_new();
          std::for_each(vector.begin(), vector.end(), [&result](const Reference_T element)
          {
            VALUE value = detail::To_Ruby<Parameter_T>().convert(element);
            rb_ary_push(result, value);
          });

          return result;
        }, Return().setValue());
      }

      void define_to_s()
      {
        if constexpr (detail::is_ostreamable_v<Value_T>)
        {
          klass_.define_method("to_s", [](const T& vector)
            {
              auto iter = vector.begin();
              auto finish = vector.size() > 1000 ? vector.begin() + 1000 : vector.end();

              std::stringstream stream;
              stream << "[";

              for (; iter != finish; iter++)
              {
                if (iter == vector.begin())
                {
                  stream << *iter;
                }
                else
                {
                  stream << ", " << *iter;
                }
              }

              stream << "]";
              return stream.str();
            });
        }
        else
        {
          klass_.define_method("to_s", [](const T& vector)
            {
              return "[Not printable]";
            });
        }
      }

      private:
        Data_Type<T> klass_;
    };
  } // namespace

  template<typename T>
  Data_Type<T> define_vector_under(Object parent, std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the vector has been previously seen it will be registered but may
      // not be associated with the constant Module::<name>
      parent.const_set_maybe(name, Data_Type<T>().klass());

      return Data_Type<T>();
    }

    Identifier id(name);
    Data_Type<T> result = define_class_under<detail::intrinsic_type<T>>(parent, id, rb_cObject);
    stl::VectorHelper helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_vector(std::string name)
  {
    if (detail::Registries::instance.types.isDefined<T>())
    {
      // If the vector has been previously seen it will be registered but may
      // not be associated with the constant Module::<name>
      Object(rb_cObject).const_set_maybe(name, Data_Type<T>().klass());

      return Data_Type<T>();
    }

    Data_Type<T> result = define_class<detail::intrinsic_type<T>>(name.c_str());
    stl::VectorHelper<T> helper(result);
    return result;
  }

  template<typename T>
  Data_Type<T> define_vector_auto()
  {
    std::string name = detail::typeName(typeid(T));
    std::string klassName = detail::makeClassName(name);
    Module rb_mRice = define_module("Rice");
    Module rb_mStd = define_module_under(rb_mRice, "Std");
    return define_vector_under<T>(rb_mStd, klassName);
  }
   
  namespace detail
  {
    template<typename T>
    struct Type<std::vector<T>>
    {
      static bool verify()
      {
        Type<intrinsic_type<T>>::verify();

        if (!detail::Registries::instance.types.isDefined<std::vector<T>>())
        {
          define_vector_auto<std::vector<T>>();
        }

        return true;
      }
    };


    template<typename T>
    class From_Ruby<std::vector<T>>
    {
    public:
      From_Ruby() = default;

      explicit From_Ruby(Arg * arg) : arg_(arg)
      {
      }

      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_ARRAY:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::vector<T> convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped vector (hopefully!)
            return *Data_Object<std::vector<T>>::from_ruby(value);
          }
          case RUBY_T_ARRAY:
          {
            // If this an Ruby array and the vector type is copyable
            if constexpr (std::is_default_constructible_v<T>)
            {
              return Array(value).to_vector<T>();
            }
          }
          case RUBY_T_NIL:
          {
            if (this->arg_ && this->arg_->hasDefaultValue())
            {
              return this->arg_->template defaultValue<std::vector<T>>();
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::vector");
          }
        }
      }

    private:
      Arg* arg_ = nullptr;
    };

    template<typename T>
    class From_Ruby<std::vector<T>&>
    {
    public:
      From_Ruby() = default;

      explicit From_Ruby(Arg * arg) : arg_(arg)
      {
      }

      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_ARRAY:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::vector<T>& convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped vector (hopefully!)
            return *Data_Object<std::vector<T>>::from_ruby(value);
          }
          case RUBY_T_ARRAY:
          {
            // If this an Ruby array and the vector type is copyable
            if constexpr (std::is_default_constructible_v<T>)
            {
              this->converted_ = Array(value).to_vector<T>();
              return this->converted_;
            }
          }
          case RUBY_T_NIL:
          {
            if (this->arg_ && this->arg_->hasDefaultValue())
            {
              return this->arg_->template defaultValue<std::vector<T>>();
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::vector");
          }
        }
      }

    private:
      Arg* arg_ = nullptr;
      std::vector<T> converted_;
    };

    template<typename T>
    class From_Ruby<std::vector<T>*>
    {
    public:
      Convertible is_convertible(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
            return Convertible::Exact;
            break;
          case RUBY_T_NIL:
            return Convertible::Exact;
            break;
          case RUBY_T_ARRAY:
            return Convertible::Cast;
            break;
          default:
            return Convertible::None;
        }
      }

      std::vector<T>* convert(VALUE value)
      {
        switch (rb_type(value))
        {
          case RUBY_T_DATA:
          {
            // This is a wrapped vector (hopefully!)
            return Data_Object<std::vector<T>>::from_ruby(value);
          }
          case RUBY_T_ARRAY:
          {
            // If this a Ruby array and the vector type is copyable
            if constexpr (std::is_default_constructible_v<T>)
            {
              this->converted_ = Array(value).to_vector<T>();
              return &this->converted_;
            }
          }
          default:
          {
            throw Exception(rb_eTypeError, "wrong argument type %s (expected % s)",
              detail::protect(rb_obj_classname, value), "std::vector");
          }
        }
      }

    private:
      std::vector<T> converted_;
    };
  }

  // Special handling for std::vector<bool>
  namespace detail
  {
    template<>
    class To_Ruby<std::vector<bool>::reference>
    {
    public:
      VALUE convert(const std::vector<bool>::reference& value)
      {
        return value ? Qtrue : Qfalse;
      }
    };
  }
}


#endif // Rice__stl__hpp_
